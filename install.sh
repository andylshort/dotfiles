#!/usr/bin/env bash
# Installation script

if ! command -v stow &> /dev/null; then
    echo "GNU Stow not installed. Please install it and try again."
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
)

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
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
    bash $HOME/.tmux/plugins/tpm/bin/install_plugins
fi

# - Install vim plugin manager and plugins
vim -es -u $HOME/.vimrc +PlugInstall +qall

# - Install fzf
ln -sf $HOME/.fzf/bin/* $HOME/.local/bin/

# - Install starship prompt
if ! command -v starship &> /dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y
fi


# Work override
if [[ -f "work/install.sh" ]]; then
    ./work/install.sh
fi
