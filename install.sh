#!/usr/bin/env bash
# Installation script
# TODO: Conditional include based on personal/work?

DOTFILES=$(dirname -- "$(readlink -f -- "$0"; )"; )

link_dir() {
    local src="$DOTFILES/$1"
    local dest="$HOME/$2"

    # Ensure the source directory actually exists
    if [[ ! -d "$src" ]]; then
        echo "Source directory $src does not exist, skipping."
        return 1
    fi

    mkdir -p "$dest"

    # Handle dotfiles correctly within the directory
    local old_dotglob
    old_dotglob=$(shopt -p dotglob)
    shopt -s dotglob

    local base
    local target

    local f
    for f in "$src"/*; do
        base=$(basename "$f")
        
        # 1. Ignore the current and parent directory pointers
        [[ "$base" == "." || "$base" == ".." ]] && continue
        
        # 2. Key Fix: Only link if it's a FILE. 
        # This prevents symlinking a subdirectory into .local/bin
        if [[ -d "$f" ]]; then
            continue
        fi

        target="$dest/$base"

        # 3. Idempotency: skip if the link is already perfect
        if [[ -L "$target" && $(readlink -f "$target") == "$(readlink -f "$f")" ]]; then
            continue
        fi

        # 4. Safety: Don't overwrite actual files that aren't symlinks
        if [[ -e "$target" && ! -L "$target" ]]; then
            echo "Conflict: $target exists and is a real file. Skipping."
            continue
        fi

        ln -snfv "$f" "$target"
    done

    eval "$old_dotglob"
}

link_file() {
    local src="$DOTFILES/$1"
    local dest="$HOME/$2"

    mkdir -p "$(dirname "$dest")"

    # If the link already exists and points to the right place, stay silent
    if [[ -L "$dest" && $(readlink "$dest") == "$src" ]]; then
        return
    fi

    if [[ -e "$dest" && ! -L "$dest" ]]; then
        echo "Skipping $dest (exists, not symlink)"
        return
    fi

    ln -snfv "$src" "$dest"
}

# scripts
link_dir scripts .local/bin
link_dir scripts/work .local/bin

# bash
link_file bash/.bashrc .bashrc
link_file bash/.bash_profile .bash_profile
link_file bash/.bash_logout .bash_logout
link_file bash/.inputrc .inputrc
link_file bash/.profile .profile

link_dir bash/.bashrc.d .bashrc.d

# git
link_file git/.gitconfig .gitconfig

# tmux
link_file tmux/.tmux.conf .tmux.conf

# vim
link_file vim/.vimrc .vimrc

# starship
link_file starship/starship.toml .config/starship.toml

# helix
link_file helix/config.toml .config/helix/config.toml

# zsh
link_file zsh/.zshrc .zshrc


# Post-linking installation steps
# - Install tmux plugin manager and plugins
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi
bash $HOME/.tmux/plugins/tpm/bin/install_plugins

# - Install vim plugin manager and plugins
vim -es -u $HOME/.vimrc +PlugInstall +qall

# - Install fzf
ln -sf $HOME/.fzf/bin/* $HOME/.local/bin/

# - Install starship prompt
if ! command -v starship &> /dev/null; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y
fi
