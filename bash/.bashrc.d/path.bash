#!/usr/bin/env bash
# Path

prepend_to_path() {
    # 1. Standardize the input (remove trailing slashes)
    local dir="${1%/}"

    # 2. Check if it's actually a directory
    [[ -d "$dir" ]] || return

    # 3. Check for exact match using colons as delimiters
    # We add colons to both ends of $PATH so we can match :$dir: 
    if [[ ":$PATH:" != *":$dir:"* ]]; then
        PATH="$dir${PATH:+:${PATH}}"
    fi
}

append_to_path() {
    local dir="${1%/}"
    [[ -d "$dir" ]] || return

    if [[ ":$PATH:" != *":$dir:"* ]]; then
        PATH="${PATH}${PATH:+:}$dir"
    fi
}

prepend_to_path "$HOME/.local/bin"
prepend_to_path "$HOME/bin"

export PATH
