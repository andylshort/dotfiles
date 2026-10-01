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

# git-pick: options, then branches/tags (either side of an A..B range).
# Named _git_pick so bash-completion's git dispatcher also picks it up for `git pick`.
_git_pick() {
    local cur=${COMP_WORDS[COMP_CWORD]} prefix='' opts
    opts='-n --dry-run -a --all -x -e --edit --no-commit -s --signoff -h --help'

    if [[ $cur == -* ]]; then
        mapfile -t COMPREPLY < <(compgen -W "$opts" -- "$cur")
        return
    fi

    git rev-parse --git-dir >/dev/null 2>&1 || return

    # Keep an already-typed "A.." / "A..." prefix and complete the right-hand side.
    if [[ $cur == *..* ]]; then
        prefix=${cur%..*}..
        [[ ${cur#"$prefix"} == .* ]] && prefix+=.
        cur=${cur#"$prefix"}
    fi

    mapfile -t COMPREPLY < <(
        compgen -P "$prefix" -W "$(
            git for-each-ref --format='%(refname:short)' \
                refs/heads refs/remotes refs/tags 2>/dev/null
        )" -- "$cur"
    )
}
complete -F _git_pick git-pick
