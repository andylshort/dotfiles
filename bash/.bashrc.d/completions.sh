#!/usr/bin/env bash
# shellcheck source=/dev/null
# Tab Completions

# 1. Only run if we are in an interactive bash shell 
# 2. Only run if bash-completion isn't already loaded
if [[ -n "$PS1" && -z "$BASH_COMPLETION_VERSINFO" ]]; then

    # Require Bash 4.2 or higher
    if (( BASH_VERSINFO[0] > 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] >= 2) )); then
        
        # Load user-specific completions if they exist
        user_completion="${XDG_CONFIG_HOME:-$HOME/.config}/bash_completion"
        [[ -r "$user_completion" ]] && source "$user_completion"

        # Load system-wide completions
        if shopt -q progcomp && [[ -r /usr/share/bash-completion/bash_completion ]]; then
            source /usr/share/bash-completion/bash_completion
        fi
    fi
fi
