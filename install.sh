#!/usr/bin/env bash
# Installation script

cd "$(dirname "$0")" || exit

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

# Each file in a package is linked to the same path under $HOME, with GNU Stow if it's
# installed, or by the loop below if not (e.g. on remotes where you can't install it)
repo="$(pwd -P)"

# Files in a package, relative to it (including the repo's own symlinks, e.g. zsh's .zshenv)
package_files() {
    (cd "$1" && find . -mindepth 1 \( -type f -o -type l \) -printf '%P\0')
}

# Move aside real files that would block a link, e.g. the ~/.bashrc most systems start with.
# Skips anything that already resolves to the repo's copy (including files reached through a
# directory stow folded into a single link)
backup_conflicts() {
    local rel target bak
    while IFS= read -r -d '' rel; do
        target="$HOME/$rel"
        if [[ -e "$target" && ! -L "$target" && "$(realpath "$target")" != "$(realpath "$1/$rel")" ]]; then
            bak="$target.bak"
            [[ -e "$bak" ]] && bak+=".$(date +%Y%m%d%H%M%S)"
            echo "-> Moving existing $target to $bak"
            mv "$target" "$bak"
        fi
    done < <(package_files "$1")
}

# Stow's job without stow: link each file (relative links, as stow makes), then remove links to
# files that have since left the repo
declare -A linked_dirs
link_package() {
    local rel target
    while IFS= read -r -d '' rel; do
        target="$HOME/$rel"
        linked_dirs["${target%/*}"]=1
        [[ "$(realpath -m "$target")" == "$(realpath "$1/$rel")" ]] && continue
        mkdir -p "${target%/*}"
        ln -sfnr "$1/$rel" "$target"
    done < <(package_files "$1")
}
prune_stale_links() {
    local dir link
    for dir in "${!linked_dirs[@]}"; do
        for link in "$dir"/.[!.]* "$dir"/*; do
            if [[ -L "$link" && ! -e "$link" && "$(realpath -m "$link")" == "$repo"/* ]]; then
                echo "-> Removing stale link $link"
                rm "$link"
            fi
        done
    done
}

command -v stow &> /dev/null && use_stow=1 || use_stow=0
((use_stow)) || echo "-> GNU Stow not found; linking files directly"
for pkg in "${packages[@]}"; do
    if [[ ! -d "$pkg" ]]; then
        echo "-> Skipping $pkg (directory not found)"
        continue
    fi
    echo "-> Linking $pkg"
    backup_conflicts "$pkg"
    if ((use_stow)); then
        # -R (restow) also removes links to files since deleted from the repo, including
        # whole packages: stow cleans up broken links into the repo in every directory it visits
        stow -R -t "$HOME" "$pkg"
    else
        link_package "$pkg"
    fi
done
((use_stow)) || prune_stale_links


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
