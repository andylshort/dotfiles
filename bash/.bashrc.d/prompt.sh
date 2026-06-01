#!/usr/bin/env bash
# Prompt

# Use non-printing wrapper \[ \] for colors in PS1 to prevent line-wrapping bugs
C_RED='\[\e[0;31m\]'
C_GRN='\[\e[0;32m\]'
C_YLW='\[\e[0;33m\]'
C_BLU='\[\e[0;34m\]'
C_PUR='\[\e[0;35m\]'
C_CYN='\[\e[0;36m\]'
C_RST='\[\e[0m\]'

F_GRY='\[\e[1;30;40m\]'

B_RED='\[\e[1;31m\]'
B_GRN='\[\e[1;32m\]'
B_YEL='\[\e[1;33m\]'
B_BLU='\[\e[1;34m\]'
B_CYN='\[\e[1;36m\]'

function get_git_info() {
    # 1. Get branch and upstream status in ONE command
    # This returns: branch_name <tab> ahead_count <tab> behind_count
    local git_info
    git_info=$(git rev-parse --abbrev-ref HEAD --symbolic-full-name '@{u}' 2>/dev/null) || return

    local branch
    local upstream
    
    branch=$(echo "$git_info" | head -n1)
    upstream=$(echo "$git_info" | tail -n1)

    # 2. Get status symbols in ONE pass without grep
    local status_symbols=""
    local has_staged=0 has_changed=0 has_untracked=0
    
    # Read git status line by line internally
    while IFS= read -r line; do
        [[ "${line:0:1}" =~ [MADRCU] ]] && has_staged=1
        [[ "${line:1:1}" =~ [MADRCU] ]] && has_changed=1
        [[ "${line:0:2}" == "??" ]] && has_untracked=1
    done < <(git status --porcelain --ignore-submodules 2>/dev/null)

    [[ $has_staged -eq 1 ]] && status_symbols+="${C_GRN}+${C_RST}"
    [[ $has_changed -eq 1 ]] && status_symbols+="${C_RED}*${C_RST}"
    [[ $has_untracked -eq 1 ]] && status_symbols+="?"

    # 3. Upstream counts
    local counts=""
    if [[ -n "$upstream" ]]; then
        local ahead_behind
        ahead_behind=$(git rev-list --left-right --count 'HEAD...@{u}' 2>/dev/null)

        local ahead
        local behind

        ahead=$(echo "$ahead_behind" | cut -f1)
        behind=$(echo "$ahead_behind" | cut -f2)
        [[ "$ahead" != "0" ]] && counts+=" ${ahead}↑"
        [[ "$behind" != "0" ]] && counts+=" ${behind}↓"
    fi

    echo -e " on ${C_PUR}${branch}${C_RST} ${status_symbols}${counts}"
}

function write_prompt() {
    local ssh_tag=""
    [[ -n "${SSH_CONNECTION}" ]] && ssh_tag="${B_RED}[ssh]${C_RST} "

    PS1="${ssh_tag}${B_CYN}\u${C_RST}@${B_GRN}\h${C_RST} in ${B_BLU}\w${C_RST}$(get_git_info)\n\$ "
}

PROMPT_COMMAND=write_prompt

function __prompt_track_start() {
    case "$BASH_COMMAND" in
        LAST_EXIT=*|history\ *|write_prompt)
            return
            ;;
    esac
    command_start_time=${SECONDS}
}

trap '__prompt_track_start' DEBUG

function write_prompt() {
    local exit_code="${LAST_EXIT:-$?}"
    PS1=""

    local statuses
    local elapsed=""

    # 2. Calculate the elapsed time
    if [[ -n "$command_start_time" ]]; then
        elapsed=$((SECONDS - command_start_time))
        unset command_start_time
    fi

    # Highlight if I'm in an SSH session
    [[ -n "${SSH_CONNECTION}" ]] && statuses+="${F_GRY} ➔ [${B_RED}ssh${F_GRY}]${C_RST}"


    if [ $exit_code -eq 0 ]; then
        statuses+="${F_GRY} ➔ [${C_RST}${B_GRN}✔${F_GRY}]${C_RST}"
    else
        statuses+="${F_GRY} ➔ [${C_RST}${B_RED}✘${C_RST} $exit_code${F_GRY}]${C_RST}"
    fi
        
    # Only show duration if the command took 1 second or longer
    if [[ -n "$elapsed" && "$elapsed" -ge 1 ]]; then
        statuses+="${F_GRY} ➔ [${C_RST}${B_YEL}${elapsed}s${F_GRY}]${C_RST}"
    fi

    local git_info
    git_info=$(get_git_info 2>/dev/null)

    PS1="${B_CYN}\u${C_RST}@${B_GRN}\h${C_RST}$statuses\n"
    PS1+="${B_BLU}\w${C_RST}${git_info}\n"
    PS1+="${F_GRY}>${C_RST} "
}
