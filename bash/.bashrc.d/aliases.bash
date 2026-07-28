#!/usr/bin/env bash
# Aliases

alias h='history'

cdls() {
    cd -- "$1" && ls -A
}

count-files() {
    # TODO: Accept parameter for directory
    find . -type f | wc -l
}
