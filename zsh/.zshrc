# variables
export VISUAL=vim
export EDITOR=$VISUAL

# history
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS


# alias
alias ls="ls -G"
alias ..="cd .."
alias ...="cd ..; cd .."
alias ez="$EDITOR ~/.zshrc"
alias g="git"
alias grep="grep --color=auto"
alias ll="ls -la"
alias py="python3"
alias python="python3"
alias rz="source ~/.zshrc"

# prompt
PROMPT="%n@%m [%~]"$'\n'"\$ "
#RPROMPT='[%D{%L:%M:%S %p}]'

# path
export PATH=$HOME/bin:$PATH

if [ "$(uname 2> /dev/null)" = "Darwin" ]; then
    test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
fi
