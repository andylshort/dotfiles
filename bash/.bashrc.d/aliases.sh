#!/usr/bin/env bash
# Aliases

# - Reload .bashrc
alias reload="source ~/.bashrc && echo 'Reloaded bash configuration!'"

# - Check if we can colourise the output of commands
if has_colors; then
    alias ls='ls --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# - Convenience aliases
alias ll='ls -lah'

alias env='env | sort'

alias h='history'

mkcd() {
    mkdir -p -- "$1" && cd -- "$1"
}

# - Trailing space rule
alias sudo='sudo '
alias xargs='xargs '
