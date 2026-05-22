#!/usr/bin/env bash
# shellcheck source=/dev/null
# .bashrc

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Only run this file if we are actually in Bash
[[ -n "$BASH_VERSION" ]] || return

# - Checks term size when bash regains control
shopt -s checkwinsize 

# - Load all of the modular .bashrc subfiles in a certain order
if [[ -d "$HOME/.bashrc.d" ]]; then
    # INFO: Don't forget to add new files to this!
    for rc in $HOME/.bashrc.d/{functions,env,path,prompt,history,aliases,completions,tools}.sh; do
        if [[ -f "$rc" ]]; then
            source "$rc"
        fi
    done
fi
unset rc

# - Local per-machine changes, e.g. work- or personal-specific settings
source_if_exists "$HOME/.bashrc.work"
source_if_exists "$HOME/.bashrc.personal"
