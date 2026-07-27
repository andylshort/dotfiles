#!/usr/bin/env bash
# Aliases

# - Check if we can colourise the output of commands
if has_colors; then
    alias ls='ls --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

alias h='history'

cdls() {
    cd -- "$1" && ls -A
}

count-files() {
    # TODO: Accept parameter for directory
    find . -type f | wc -l
}
