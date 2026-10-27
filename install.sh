#!/usr/bin/env bash
# Installation script

cd "$(dirname "$0")" || exit

# TODO: Check all prerequisites, or have gated install/config
if ! command -v stow &> /dev/null; then
    echo "GNU Stow not installed. Please install it and try again."
    exit 1
fi
if ! command -v entr &> /dev/null; then
    echo "entr not installed. Please install it and try again."
    exit 1
fi

packages=(
    common
    
    bash
    ghostty
    git
    helix
    nvim
    scripts
    starship
    tmux
    vim
    zsh

    atuin
    kde
)

# Completions live here; create it before stowing so stow links individual files into
# it rather than folding the whole directory into a symlink back at the repo.
COMP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/completions"
mkdir -p "$COMP_DIR"
# Likewise for autostart entries, so ones added via System Settings don't land in the repo
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/autostart"

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

# - Install tmux plugin manager and plugins
TPM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    bash "$TPM_DIR/bin/install_plugins"
fi

# - Install vim plugin manager and plugins
vim -es -u $HOME/.vimrc +PlugInstall +qall

# - Install Neovim (>= 0.12 for vim.pack) from the official release if the system one is
#   missing or too old. Lives in ~/.local so it works on remotes without root; if the binary
#   can't run (e.g. ancient glibc) it's removed again and EDITOR falls back to vim
export PATH="$HOME/.local/bin:$PATH"
NVIM_OK='vim.fn.has("nvim-0.12") == 1 and 0 or 1'
if ! nvim --headless -u NONE "+lua os.exit($NVIM_OK)" &> /dev/null; then
    case "$(uname -m)" in
        x86_64) nvim_arch=x86_64 ;;
        aarch64 | arm64) nvim_arch=arm64 ;;
        *) nvim_arch= ;;
    esac
    if [[ -n "$nvim_arch" ]]; then
        echo "-> Installing Neovim ($nvim_arch) to ~/.local/opt"
        mkdir -p "$HOME/.local/opt" "$HOME/.local/bin"
        rm -rf "$HOME/.local/opt/nvim-linux-$nvim_arch"
        curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-$nvim_arch.tar.gz" |
            tar xz -C "$HOME/.local/opt"
        ln -sf "$HOME/.local/opt/nvim-linux-$nvim_arch/bin/nvim" "$HOME/.local/bin/nvim"
        if ! "$HOME/.local/bin/nvim" --headless -u NONE "+lua os.exit($NVIM_OK)" &> /dev/null; then
            echo "-> Downloaded Neovim won't run here; removing it (vim config still works)"
            rm -rf "$HOME/.local/bin/nvim" "$HOME/.local/opt/nvim-linux-$nvim_arch"
        fi
    fi
fi
# - Install tree-sitter CLI (>= 0.26.1, for building Neovim parsers) the same way. The release
#   binary needs a recent glibc, so on older machines Neovim just keeps regex highlighting
ts_ok() {
    local v
    v=$("$1" --version 2>/dev/null | awk '{print $2}') || return 1
    [[ -n "$v" && "$(printf '%s\n' 0.26.1 "$v" | sort -V | head -1)" == 0.26.1 ]]
}
if ! ts_ok tree-sitter; then
    case "$(uname -m)" in
        x86_64) ts_arch=x64 ;;
        aarch64 | arm64) ts_arch=arm64 ;;
        *) ts_arch= ;;
    esac
    if [[ -n "$ts_arch" ]]; then
        echo "-> Installing tree-sitter CLI ($ts_arch) to ~/.local/bin"
        mkdir -p "$HOME/.local/bin"
        curl -fsSL "https://github.com/tree-sitter/tree-sitter/releases/latest/download/tree-sitter-linux-$ts_arch.gz" |
            gunzip > "$HOME/.local/bin/tree-sitter" && chmod +x "$HOME/.local/bin/tree-sitter"
        if ! ts_ok "$HOME/.local/bin/tree-sitter"; then
            echo "-> Downloaded tree-sitter won't run here; removing it (no treesitter highlighting)"
            rm -f "$HOME/.local/bin/tree-sitter"
        fi
    fi
fi

# - Install Neovim plugins (vim.pack installs anything missing on startup, at the locked revisions)
#   and treesitter parsers, if a C compiler and tree-sitter are available to build them
if command -v nvim &> /dev/null; then
    nvim --headless +qa
    if command -v tree-sitter &> /dev/null && command -v cc &> /dev/null; then
        echo "-> Installing treesitter parsers"
        nvim --headless \
            "+lua require('nvim-treesitter').install(vim.g.ts_parsers):wait(600000)" +qa
    else
        echo "-> Skipping treesitter parsers (needs tree-sitter CLI and a C compiler)"
    fi
fi

# - Install fzf
ln -sf $HOME/.fzf/bin/* $HOME/.local/bin/

# - Install starship prompt
if ! command -v starship &> /dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# - Install delta (git pager). Optional: the git config falls back to less if it's missing
if ! command -v delta &> /dev/null; then
    SUDO=()
    if [[ $EUID -ne 0 ]] && command -v sudo &> /dev/null; then
        SUDO=(sudo)
    fi

    if command -v dnf &> /dev/null; then
        delta_install=("${SUDO[@]}" dnf install -y git-delta)
    elif command -v apt-get &> /dev/null; then
        delta_install=("${SUDO[@]}" apt-get install -y git-delta)
    elif command -v zypper &> /dev/null; then
        delta_install=("${SUDO[@]}" zypper install -y git-delta)
    else
        delta_install=()
    fi

    if (( ${#delta_install[@]} )); then
        echo "-> Installing delta: ${delta_install[*]}"
        "${delta_install[@]}" || echo "-> Failed to install delta; git will fall back to less"
    else
        echo "-> No supported package manager found for delta; git will fall back to less"
    fi
fi

# - Install atuin and shell completions
export PATH="$HOME/.atuin/bin:$PATH"
if ! command -v atuin &> /dev/null; then
    # Use the release installer directly: setup.atuin.sh appends init lines to .zshrc/.bashrc
    curl --proto '=https' --tlsv1.2 -LsSf https://github.com/atuinsh/atuin/releases/latest/download/atuin-installer.sh |
        ATUIN_NO_MODIFY_PATH=1 sh
fi

atuin gen-completions --shell zsh --out-dir "$COMP_DIR"

# - Enable KWin scripts
if command -v kwriteconfig6 &> /dev/null; then
    kwriteconfig6 --file kwinrc --group Plugins --key first-window-desktopEnabled true
fi


# Work override
if [[ -f "work/install.sh" ]]; then
    ./work/install.sh
fi
