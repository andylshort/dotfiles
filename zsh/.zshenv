# ~/.zshenv

# XDG Base Directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

# Define config directory for the rest of Zsh
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"


export PATH="$HOME/.local/bin:$PATH"

export EDITOR="vim"
export VISUAL="vim"

export BROWSER="firefox"

export LESS="-R" # Preserves colors when piping commands to less