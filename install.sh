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
)

# Completions live here; create it before stowing so stow links individual files into
# it rather than folding the whole directory into a symlink back at the repo.
COMP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/completions"
mkdir -p "$COMP_DIR"
# Likewise for autostart entries, so ones added via System Settings don't land in the repo
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/autostart"
# And desktop entries, which KDE also writes here
mkdir -p "${XDG_DATA_HOME:-$HOME/.local/share}/applications"
# And Claude skills: without this stow would fold all of ~/.claude into the repo
mkdir -p "$HOME/.claude/skills"

# Each file in a package is linked to the same path under $HOME, with GNU Stow if it's
# installed, or by the loop below if not (e.g. on remotes where you can't install it)
repo="$(pwd -P)"

# Output: only what changed, indented (sync-dotfiles-to prints a heading per host)
say() { echo "  $*"; }
tilde() { echo "${1/#"$HOME"/\~}"; }

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
            say "Backed up $(tilde "$target") -> $(tilde "$bak")"
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
                say "Removed stale link $(tilde "$link")"
                rm "$link"
            fi
        done
    done
}

command -v stow &> /dev/null && use_stow=1 || use_stow=0
linked=0
for pkg in "${packages[@]}"; do
    [[ -d "$pkg" ]] || continue
    linked=$((linked + 1))
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
if ((use_stow)); then say "Linked $linked packages (stow)"; else say "Linked $linked packages (no stow; linked directly)"; fi


# Post-linking installation steps
# - Move shell history from $HOME to XDG_STATE_HOME (one-off; never overwrites)
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}"
for hist in "zsh:.zsh_history" "bash:.bash_history"; do
    shell="${hist%%:*}" old="$HOME/${hist#*:}" new="$STATE_DIR/${hist%%:*}/history"
    if [[ -f "$old" && ! -e "$new" ]]; then
        say "Moved $(tilde "$old") to $(tilde "$new")"
        mkdir -p "$STATE_DIR/$shell"
        mv "$old" "$new"
    fi
done

# - Remove things this repo no longer uses: TPM's tmux plugins (~/.config/tmux may be stowed
#   back into this repo, where they'd show up as untracked) and zinit
for old in "${XDG_CONFIG_HOME:-$HOME/.config}/tmux/plugins" "${XDG_DATA_HOME:-$HOME/.local/share}/zinit"; do
    if [[ -d "$old" ]]; then
        say "Removed $(tilde "$old") (no longer used)"
        rm -rf "$old"
    fi
done

# Optional extras. Nothing is downloaded as a binary: tools come from the system's packages
# (see required-packages.txt), and the configs work without any of them
# - zsh plugins: plain git clones, sourced by .zshrc if present. Time-limited, so hosts without
#   internet access don't hang
PLUGIN_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins"
for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
    if [[ -d "$PLUGIN_DIR/$plugin" ]]; then
        timeout 15 git -C "$PLUGIN_DIR/$plugin" pull -q --ff-only &> /dev/null ||
            say "Couldn't update $plugin (no internet?)"
    elif timeout 30 git clone -q --depth 1 "https://github.com/zsh-users/$plugin" "$PLUGIN_DIR/$plugin" &> /dev/null; then
        say "Installed $plugin"
    else
        rm -rf "${PLUGIN_DIR:?}/$plugin"
        say "Couldn't install $plugin (no internet?); zsh works without it"
    fi
done

# - Neovim (>= 0.12) plugins at their locked revisions, and treesitter parsers if there's a
#   tree-sitter CLI and C compiler to build them (otherwise Neovim uses regex highlighting).
#   Their progress output is long, so it goes to a log
NVIM_LOG="${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles-nvim-setup.log"
if nvim --headless -u NONE '+lua os.exit(vim.fn.has("nvim-0.12") == 1 and 0 or 1)' &> /dev/null; then
    mkdir -p "${NVIM_LOG%/*}"
    {
        nvim --headless +qa
        if command -v tree-sitter && command -v cc; then
            nvim --headless "+lua require('nvim-treesitter').install(vim.g.ts_parsers):wait(600000)" +qa
        fi
    } &> "$NVIM_LOG"
    if grep -qiE 'error|fail' "$NVIM_LOG"; then
        say "Neovim plugin/parser setup had errors; see $(tilde "$NVIM_LOG")"
    fi
fi

# - Open text files (e.g. clicked file:// links) in Neovim in tmux: make tmux-edit.desktop the
#   default for each type it lists. xdg-mime edits ~/.config/mimeapps.list, which isn't stowed
#   since KDE rewrites it. Only on desktops: remotes have no xdg-mime or no session
desktop="${XDG_DATA_HOME:-$HOME/.local/share}/applications/tmux-edit.desktop"
if [[ -f "$desktop" && -n "${WAYLAND_DISPLAY:-}${DISPLAY:-}" ]] && command -v xdg-mime &> /dev/null; then
    mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}"
    IFS=';' read -ra types < <(sed -n 's/^MimeType=//p' "$desktop")
    # Quiet: under KDE it looks for a Qt 5 qtpaths for each type, then falls back to ~/.config
    xdg-mime default tmux-edit.desktop "${types[@]}" 2> /dev/null ||
        say "Couldn't set tmux-edit as the default for text files"
fi

# - atuin completions
if command -v atuin &> /dev/null; then
    atuin gen-completions --shell zsh --out-dir "$COMP_DIR"
fi

# - Remove the old first-window-desktop KWin script (sent apps to named virtual desktops,
#   which no longer exist): its link, its enabled flag, and the copy KWin has loaded
#   (stow may have folded the link into any of these directories, now left dangling)
kwin_dir="${XDG_DATA_HOME:-$HOME/.local/share}/kwin"
for old in "$kwin_dir/scripts/first-window-desktop" "$kwin_dir/scripts" "$kwin_dir"; do
    if [[ -L "$old" && ! -e "$old" ]]; then
        say "Removed $(tilde "$old") (no longer used)"
        rm "$old"
    fi
done
if command -v kwriteconfig6 &> /dev/null; then
    kwriteconfig6 --file kwinrc --group Plugins --key first-window-desktopEnabled --delete
    command -v qdbus-qt6 &> /dev/null &&
        qdbus-qt6 org.kde.KWin /Scripting org.kde.kwin.Scripting.unloadScript first-window-desktop &> /dev/null
fi


# Work override
if [[ -f "work/install.sh" ]]; then
    ./work/install.sh
fi
