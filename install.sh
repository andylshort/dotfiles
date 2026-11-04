#!/usr/bin/env bash
# Installation script

cd "$(dirname "$0")" || exit

if ! command -v stow &> /dev/null; then
    echo "GNU Stow not installed. Please install it and try again."
    exit 1
fi

packages=(
    bash
    ghostty
    git
    nvim
    scripts
    tmux
    vim
    zsh

    atuin
    claude
    kde
)

# Completions live here; create it before stowing so stow links individual files into
# it rather than folding the whole directory into a symlink back at the repo.
COMP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/completions"
mkdir -p "$COMP_DIR"
# Likewise for autostart entries, so ones added via System Settings don't land in the repo
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/autostart"
# And Claude skills: without this stow would fold all of ~/.claude into the repo
mkdir -p "$HOME/.claude/skills"

# Links to files since removed from the repo (including whole packages, like the old
# common/) are cleaned up by stow itself: it deletes broken links into the repo in every
# directory it visits
for pkg in "${packages[@]}"; do
    # Check if the folder actually exists before trying to stow it
    if [[ -d "$pkg" ]]; then
        echo "-> Stowing $pkg"
        # -R (restow) also prunes links to files that no longer exist in the package
        stow -R -t "$HOME" "$pkg"
    else
        echo "-> Skipping $pkg (directory not found)"
    fi
done


# Post-linking installation steps
# - Move shell history from $HOME to XDG_STATE_HOME (one-off; never overwrites)
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}"
for hist in "zsh:.zsh_history" "bash:.bash_history"; do
    shell="${hist%%:*}" old="$HOME/${hist#*:}" new="$STATE_DIR/${hist%%:*}/history"
    if [[ -f "$old" && ! -e "$new" ]]; then
        echo "-> Moving $old to $new"
        mkdir -p "$STATE_DIR/$shell"
        mv "$old" "$new"
    fi
done

# - Remove things this repo no longer uses: TPM's tmux plugins (~/.config/tmux may be stowed
#   back into this repo, where they'd show up as untracked) and zinit
for old in "${XDG_CONFIG_HOME:-$HOME/.config}/tmux/plugins" "${XDG_DATA_HOME:-$HOME/.local/share}/zinit"; do
    if [[ -d "$old" ]]; then
        echo "-> Removing $old (no longer used)"
        rm -rf "$old"
    fi
done

# Optional extras. Nothing is downloaded as a binary: tools come from the system's packages
# (see required-packages.txt), and the configs work without any of them
# - zsh plugins: plain git clones, sourced by .zshrc if present
PLUGIN_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"
for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
    if [[ -d "$PLUGIN_DIR/$plugin" ]]; then
        git -C "$PLUGIN_DIR/$plugin" pull -q --ff-only || echo "-> Couldn't update $plugin"
    else
        git clone -q --depth 1 "https://github.com/zsh-users/$plugin" "$PLUGIN_DIR/$plugin" ||
            echo "-> Couldn't clone $plugin; zsh works without it"
    fi
done

# - Neovim (>= 0.12) plugins at their locked revisions, and treesitter parsers if there's a
#   tree-sitter CLI and C compiler to build them (otherwise Neovim uses regex highlighting)
if nvim --headless -u NONE '+lua os.exit(vim.fn.has("nvim-0.12") == 1 and 0 or 1)' &> /dev/null; then
    nvim --headless +qa
    if command -v tree-sitter &> /dev/null && command -v cc &> /dev/null; then
        echo "-> Installing treesitter parsers"
        nvim --headless "+lua require('nvim-treesitter').install(vim.g.ts_parsers):wait(600000)" +qa
    fi
fi

# - atuin completions
if command -v atuin &> /dev/null; then
    atuin gen-completions --shell zsh --out-dir "$COMP_DIR"
fi

# - Enable KWin scripts
if command -v kwriteconfig6 &> /dev/null; then
    kwriteconfig6 --file kwinrc --group Plugins --key first-window-desktopEnabled true
fi


# Work override
if [[ -f "work/install.sh" ]]; then
    ./work/install.sh
fi
