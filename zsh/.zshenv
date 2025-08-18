# Make ZSH use the XDG directory spec
# https://wiki.archlinux.org/title/XDG_Base_Directory
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"


export EDITOR="vim"
export VISUAL="vim"

export BROWSER="google-chrome"


# History
export HISTFILE="$ZDOTDIR/.zsh_history"
export HISTSIZE=1000000
export SAVEHIST=200000000
