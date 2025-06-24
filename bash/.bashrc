# Code that needs to run before the main bash setup
[[ -r "$HOME/.bashrc.pre" ]] && source "$HOME/.bashrc.pre"

# Set up the environment
export VISUAL="vim"
export EDITOR="vim"

export MODULEPATH=$MODULEPATH:"$HOME/modules/"

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

export PATH=$PATH:"/Library/TeX/texbin/"

# History settings
[[ -z "$HISTFILE" ]] && HISTFILE=$HOME/.bash_history
export HISTTIMEFORMAT="%F %T "
# Save 10000 history lines in memory
export HISTSIZE=10000
# SAve 200M lines on disk
export HISTFILESIZE=200000000
# Append to the history, instead of overwriting
shopt -s histappend
# Ignore duplicates or space-preceding commands
export HISTCONTROL=ignoreboth:erasedups
# Ignore useless commands
export HISTIGNORE='ls:ll:ls -alh:pwd:clear:history'
# Multiple commands on one line show up as a single line
shopt -s cmdhist

# Aliases
alias ..="cd ..;"
alias g="git"
alias m="module"
alias mkdir="mkdir -p"
alias rsh="source $HOME/.bashrc"

# Functions
function mcd() {
  mkdir -p -- "$@" && cd -- "$_";
}

function env() {
  command env $@ | sort;
}

# SSH auto-completion based on entries in known_hosts.
if [[ -e $HOME/.ssh/known_hosts ]]; then
  complete -o default -W "$(cat $HOME/.ssh/known_hosts | sed 's/[, ].*//' | sort | uniq | grep -v '[0-9]')" ssh scp stfp
fi

# Prompt
function parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

function write_prompt() {
  local EXIT=$?
  PS1=""

  history -a
  history -c
  history -r

  # Start printing prompt on newline if cursor not in first column
  shopt -s promptvars
  PS1='$(printf "%$((COLUMNS-1))s\r")'$PS1

  # Write the return code and timestamp out after the first command
  if [[ -z "${PS1_NEWLINE_LOGIN}" ]]; then
    PS1_NEWLINE_LOGIN=true
  else
    if [ $EXIT == 0 ]; then
      PS1+="\e[32m✔\e[90m \A\e[00m\n"
    else
      PS1+="\e[31m✘\e[90m \A\e[00m\n"
    fi
  fi

  # Current user, host, path
  PS1+="\u@\h \[\033[36m\]\w\[\033[00m\]\n"
  
  # Append the current git branch if in a repo, on a new line
  if $(git status -s &> /dev/null)
  then
    if [[ $(git status --porcelain) == "" ]]
    then
      PS1+="\e[32m⊻ $(parse_git_branch)\e[00m\n"
    else
      PS1+="\e[31m⊻ $(parse_git_branch)*\e[00m\n"
    fi
  fi

  PS1+="\$ "
}

# Set the prompt via this command (runes once before each prompt is set)
PROMPT_COMMAND=write_prompt

# Load local (per computer) bashrc settings if available
[[ -r "$HOME/.bashrc.local" ]] && source "$HOME/.bashrc.local"

# vi:ft=sh

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
