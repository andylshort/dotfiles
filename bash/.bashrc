# If not running interactively, don't do anything
case $- in
    *i*) ;;
    *) return;;
esac

# +--------------------------+
# | Table of Contents        |
# +--------------------------+
# | 1. Environment variables |
# | 2. History               |
# | 3. Display               |
# | 4. Functions             |
# | 5. Aliases               |
# | 6. Prompt                |
# | 7. Auto-completion       |
# +--------------------------+

# Code that needs to run before the main bash setup
[[ -r "$HOME/.bashrc.pre" ]] && source "$HOME/.bashrc.pre"

# +-----------------------+
# | Environment Variables |
# +-----------------------+

# Set up the environment
export VISUAL="vim"
export EDITOR="vim"
export BROWSER="google-chrome"

export VIRTUAL_ENV_DISABLE_PROMPT=1

# Remote connection-specific settings
if [ -n "$SSH_TTY" ] || [ -n "$SSH_CONNECTION"] || [ -n "$SSH_CLIENT" ]; then
    # Set the GPG input to the terminal, rather than open the GUI program
    export GPG_TTY=$(tty)
    export TERM=xterm-256color
fi

# Prefer GB English and use UTF-8.
export LC_ALL=en_GB.UTF-8
export LANG=en_GB.UTF-8
export LANGUAGE=en_GB.UTF-8

# Fuzzy finder (fzf)
# Open up a preview window (hidden by default) using '?' to toggle it
# Useful when searching for long commands in your command history
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:6:hidden:wrap --bind '?:toggle-preview'"

# +---------+
# | History |
# +---------+

[[ -z "$HISTFILE" ]] && HISTFILE=$HOME/.bash_history
HISTTIMEFORMAT="%F %T "
# Save 10000 history lines in memory
HISTSIZE=10000
# Save 200M lines on disk
HISTFILESIZE=200000000
# Append to the history, instead of overwriting
shopt -s histappend
# Ignore duplicates or space-preceding commands
HISTCONTROL=ignoreboth
# Ignore useless commands
HISTIGNORE='ls:ll:ls -alh:pwd:clear:history'
# Multiple commands on one line show up as a single line
shopt -s cmdhist


# +---------+
# | Display |
# +---------+

# Resize after each command
shopt -s checkwinsize


# +-----------+
# | Functions |
# +-----------+

function parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

function set_virtualenv () {
    if test -z "$VIRTUAL_ENV" ; then
        PYTHON_VIRTUALENV=""
    else
        PYTHON_VIRTUALENV="(`basename \"$VIRTUAL_ENV\"`) "
    fi
}

function mcd() {
    mkdir -p -- "$@" && cd -- "$_";
}

function env() {
    command env $@ | sort;
}

# +---------+
# | Aliases |
# +---------+

# Enable colour support of various commands if supported
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
fi

# Directory traversal and management
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias tree='tree -C'

alias mkdir="mkdir -p"

alias ..="cd ..;"

# Git
alias g="git"
alias gcm="git checkout master"
alias grm="git rebase master"

alias gpl="git pull --recurse-submodules"

# Reload bash configuration file to apply changes
alias rebash='exec bash'

# tmux
alias ta="tmux attach-session -t $1"
alias tn="tmux new-session -s $1"


# +--------+
# | Prompt |
# +--------+

function write_prompt() {
    # TODO: Handle case where colors aren't available?
    local EXIT=$?
    PS1=""

    # Set colour mode if able
    case "$TERM" in
        xterm-color|*-256color) colour_prompt=yes;;
    esac

    # Set colours
    local GREEN='\[\e[0;32m\]'
    local MAGENTA='\[\e[0;35m\]'
    local BLUE='\[\e[0;34m\]'
    local GREY='\[\e[0;90m\]'
    local RESET='\[\e[0m\]'

    local BOLD_GREEN='\[\e[1;32m\]'
    local BOLD_BLUE='\[\e[1;34m\]'

    if [[ -z "$colour_prompt" ]]; then
        GREEN=''
        MAGENTA=''
        BLUE=''
        GREY=''
        RESET=''

        BOLD_GREEN=''
        BOLD_BLUE=''
    fi

    # Start printing prompt on newline if cursor not in first column
    shopt -s promptvars
    PS1='$(printf "%$((COLUMNS-1))s\r")'$PS1

    # Write the return code and timestamp out after the first command
    if [[ -z "${PS1_NEWLINE_LOGIN}" ]]; then
        PS1_NEWLINE_LOGIN=true
    else
        if [ $EXIT == 0 ]; then
            PS1+="${GREEN}✔${GREY} \A${RESET}\n"
        else
            PS1+="${MAGENTA}✘${GREY} \A${RESET}\n"
        fi
    fi

    # Programming-specific information
    set_virtualenv

    # Current user, host, path
    PS1+="${BOLD_GREEN}\u${RESET}@${GREEN}\h${RESET}"

    # Append the current git branch if in a repo, on a new line
    if $(git status -s &> /dev/null); then
        if [[ $(git status --porcelain) == "" ]]; then
            PS1+=" ${GREEN}(⊻ $(parse_git_branch))${RESET}"
        else
            PS1+=" ${MAGENTA}(⊻ $(parse_git_branch)*)${RESET}"
        fi
    fi
    PS1+="\n"
    PS1+="${BOLD_BLUE}\$PWD${RESET}\n"

    # Add virtualenv info
    PS1+="${PYTHON_VIRTUALENV}"

    # Add command indicator
    PS1+="${GREEN}>${RESET} "
    unset colour_prompt
}

# Set the prompt via this command (runes once before each prompt is set)
PROMPT_COMMAND=write_prompt


# +-----------------+
# | Auto-completion |
# +-----------------+

# Built-in
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
fi
# Custom
if [ -f ~/.bash_completion ]; then
    . ~/.bash_completion
fi


# Load local (per computer) bashrc settings if available
[[ -r "$HOME/.bashrc.local" ]] && source "$HOME/.bashrc.local"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# vi:ft=sh
