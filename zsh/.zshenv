export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"


export LC_ALL="en_GB.UTF-8"
export LANG="en_GB.UTF-8"
export LC_NUMERIC="en_GB"


export EDITOR="nvim"
export VISUAL="nvim"

export BROWSER="firefox"


# History
export HISTFILE="$ZDOTDIR/.zsh_history"
export HISTSIZE=100000
export SAVEHIST=200000000

