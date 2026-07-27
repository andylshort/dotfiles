#!/usr/bin/env zsh

# Uncomment to profile speed
# zmodload zsh/zprof

ZDOTDIR="${ZDOTDIR:-$XDG_CONFIG_HOME/zsh}"

# Common aliases and functionality
[[ -d "$XDG_CONFIG_HOME/aliases" ]] && source "$XDG_CONFIG_HOME/aliases"

# Source all files in conf.d in numerical order
for file in "$ZDOTDIR/conf.d/"*.zsh; do
    source "$file"
done
unset file


# Work-specific configs loaded last as they're usually overrides
if [[ -f "$HOME/.zshrc.work" ]]; then
    source "$HOME/.zshrc.work"
fi

# Uncomment to profile speed
# zprof
