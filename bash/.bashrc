# Ensure only runs when in interactive mode
[[ $- != *i* ]] && return;

# Code that needs to run before the main bash setup
[[ -r "$HOME/.bashrc.pre" ]] && source "$HOME/.bashrc.pre"

# Set up the environment
export VISUAL="vim"
export EDITOR="vim"
export BROWSER="firefox"

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
export HISTCONTROL=ignoreboth
# Ignore useless commands
export HISTIGNORE='ls:ll:ls -alh:pwd:clear:history'
# Multiple commands on one line show up as a single line
shopt -s cmdhist

# Aliases
# Expand aliases (testing, might remove)
shopt -s expand_aliases

alias ..="cd ..;"
alias cp="cp -i" # Confirm before overwrite
alias df="df -h" # Human-readable sizes
alias free="free -m" # Show sizes in MB
alias g="git"
alias grep="grep --color=auto"
alias ls="ls --color=auto"
alias mkdir="mkdir -p"
alias rm="rm -i" # Confirm before deletion
alias rsh="source $HOME/.bashrc"

# Functions
env() { command env $@ | sort; }
mcd() { mkdir -p -- "$@" && cd -- "$_"; }

# ex - archive extractor
# usage: ex <file>
ex ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1     ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# SSH auto-completion based on entries in known_hosts.
if [[ -e $HOME/.ssh/known_hosts ]]; then
  complete -o default -W "$(cat $HOME/.ssh/known_hosts | sed 's/[, ].*//' | sort | uniq | grep -v '[0-9]')" ssh scp stfp
fi

# Prompt
parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'
}

set_virtualenv() {
  if test -z "$VIRTUAL_ENV" ; then
    PYTHON_VIRTUALENV=""
  else
    PYTHON_VIRTUALENV="(`basename \"$VIRTUAL_ENV\"`)"
  fi
}

write_prompt() {
  local EXIT=$?
  PS1=""

  # Start printing prompt on newline if cursor not in first column
  shopt -s promptvars
  PS1='$(printf "%$((COLUMNS-1))s\r")'$PS1

  set_virtualenv

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

  if [[ ${EUID} == 0 ]]; then
      PS1+="\[\033[1;31m\]su\[\033[00m\] "
  fi


  PS1+="${PYTHON_VIRTUALENV}\$ "
}

# Set the prompt via this command (runes once before each prompt is set)
PROMPT_COMMAND=write_prompt

# Bash auto-completion
[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion


# Bash won't get SIGWINCH if another process is in the foreground.
# Enable checkwinsize so that bash will check the terminal size when
# it regains control.  #65623
# http://cnswww.cns.cwru.edu/~chet/bash/FAQ (E11)
shopt -s checkwinsize


# Load local (per computer) bashrc settings if available
[[ -r "$HOME/.bashrc.local" ]] && source "$HOME/.bashrc.local"

# vi:ft=sh
