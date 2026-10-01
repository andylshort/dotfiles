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
    scripts
    starship
    tmux
    vim
    zsh

    atuin
)

# Completions live here; create it before stowing so stow links individual files into
# it rather than folding the whole directory into a symlink back at the repo.
COMP_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/zsh/completions"
mkdir -p "$COMP_DIR"

for pkg in "${packages[@]}"; do
    # Check if the folder actually exists before trying to stow it
    if [[ -d "$pkg" ]]; then
        echo "-> Stowing $pkg"
        stow -t "$HOME" "$pkg"
    else
        echo "-> Skipping $pkg (directory not found)"
    fi
done


# Post-linking installation steps
# - Install tmux plugin manager and plugins
TPM_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    bash "$TPM_DIR/bin/install_plugins"
fi

# - Install vim plugin manager and plugins
vim -es -u $HOME/.vimrc +PlugInstall +qall

# - Install fzf
ln -sf $HOME/.fzf/bin/* $HOME/.local/bin/

# - Install starship prompt
if ! command -v starship &> /dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y
fi

# - Install atuin and shell completions
export PATH="$HOME/.atuin/bin:$PATH"
if ! command -v atuin &> /dev/null; then
    # Use the release installer directly: setup.atuin.sh appends init lines to .zshrc/.bashrc
    curl --proto '=https' --tlsv1.2 -LsSf https://github.com/atuinsh/atuin/releases/latest/download/atuin-installer.sh |
        ATUIN_NO_MODIFY_PATH=1 sh
fi

atuin gen-completions --shell zsh --out-dir "$COMP_DIR"


# Work override
if [[ -f "work/install.sh" ]]; then
    ./work/install.sh
fi
