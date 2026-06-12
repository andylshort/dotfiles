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

# 1. The Fix: Separated Branch and Upstream Logic

# Instead of relying on git rev-parse to grab both the branch and upstream at the exact same time, the script now uses git symbolic-ref --short HEAD to just get the branch name. This always works locally. The upstream check is moved further down inside an if block that fails gracefully if no upstream exists.
# 2. Upgrade: Detached HEAD Safety

# If you ever checkout a specific commit hash or an interactive rebase gets paused, your old function would break or show nothing. The update checks if branch is empty, and if so, safely outputs detached@abc123f.
# 3. Upgrade: Merge Conflict Indicator (✘)

# Your original while loop looked for changes and staged files, but missed merge conflicts. If you hit a conflict, git status --porcelain outputs codes like UU or AA. The upgraded loop explicitly checks for these and appends a sharp red ✘ so you immediately know your repository is in a broken state.
# 4. Upgrade: Untracked/No-Upstream Indicator (☁!)

# When a branch has no upstream tracking branch (like when you just ran git checkout -b feature-branch), the function now adds a subtle yellow ☁! (or whatever symbol you prefer) to visually remind you that this branch only exists on your local machine and hasn't been pushed to GitHub/GitLab yet.
function get_git_info() {
    # Ensure we are inside a git repo first
    git rev-parse --is-inside-work-tree &>/dev/null || return

    # 1. Get branch name safely without assuming upstream exists
    local branch
    branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    if [[ -z "$branch" ]]; then
        branch=$(git rev-parse --short HEAD 2>/dev/null)
        branch="detached@${branch}"
    fi

    # 2. Dump the entire status into a single variable at once.
    local git_status
    git_status=$(git status --porcelain --ignore-submodules 2>/dev/null)

    local status_symbols=""
    
    # Check for conflicts
    if [[ "$git_status" =~ (DD|AU|UD|UA|DU|AA|UU) ]]; then
        status_symbols+="${C_RED}✘${C_RST}"
    fi
    # Check for staged changes (Any line starting with M, A, D, R, C at the index)
    if [[ "$git_status" =~ ^[MADRC] ]]; then
        status_symbols+="${C_GRN}+${C_RST}"
    fi
    # Check for unstaged modifications (Any line with M, A, D, R, C, U in the working tree column)
    if [[ "$git_status" =~ ^.[MADRCU] ]]; then
        status_symbols+="${C_RED}*${C_RST}"
    fi
    # Check for untracked files
    if [[ "$git_status" =~ \?\? ]]; then
        status_symbols+="?"
    fi

    # 3. Upstream counts (Only runs if upstream exists, preventing the crash)
    local counts=""
    if git rev-parse --symbolic-full-name '@{u}' &>/dev/null; then
        local ahead_behind
        ahead_behind=$(git rev-list --left-right --count 'HEAD...@{u}' 2>/dev/null)

        local ahead behind
        ahead=$(echo "$ahead_behind" | cut -f1)
        behind=$(echo "$ahead_behind" | cut -f2)
        
        [[ "$ahead" -gt 0 ]] && counts+=" ${ahead}↑"
        [[ "$behind" -gt 0 ]] && counts+=" ${behind}↓"
    else
        counts+=" ${C_YEL}☁ !${C_RST}" 
    fi

    echo -e " on ${C_PUR}${branch}${C_RST}${status_symbols}${counts}"
}

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

    local statuses=""
    local elapsed=""

    # 2. Calculate the elapsed time
    if [[ -n "$command_start_time" ]]; then
        elapsed=$((SECONDS - command_start_time))
        unset command_start_time
    fi

    # Highlight if I'm in an SSH session
    [[ -n "${SSH_CONNECTION}" ]] && statuses+=" ${B_RED}via ssh${C_RST}"

    statuses+="${F_GRY} ["

    if [ $exit_code -eq 0 ]; then
        statuses+="${B_GRN}✔${C_RST}"
    else
        statuses+="${B_RED}✘ ${F_GRY}$exit_code${C_RST}"
    fi
        
    # Only show duration if the command took 1 second or longer
    if [[ -n "$elapsed" && "$elapsed" -ge 1 ]]; then
        statuses+="${F_GRY}; took ${C_RST}${B_YEL}${elapsed}s${C_RST}"
    fi

    statuses+="${F_GRY}]${C_RST}"

    local git_info
    git_info=$(get_git_info 2>/dev/null)

    PS1="${B_CYN}\u${F_GRY} on ${B_GRN}\h${C_RST}$statuses
🛸 ${B_BLU}\w${C_RST}${git_info}
${F_GRY}\$${C_RST} "
}

PROMPT_COMMAND=write_prompt
