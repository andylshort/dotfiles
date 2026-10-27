#!/usr/bin/env bash
# Environment Variables
# - More specific ones go in their own script, global ones are kept here

export DOTFILES="$HOME/dotfiles"

# Prefer Neovim where install.sh managed to provide it
if command -v nvim &> /dev/null || [[ -x "$HOME/.local/bin/nvim" ]]; then
    export EDITOR="nvim"
else
    export EDITOR="vim"
fi
export VISUAL="$EDITOR"

export LC_ALL="en_GB.UTF-8"
export LC_LANG="en_GB.UTF-8"
export LC_LANGUAGE="en_GB.UTF-8"
