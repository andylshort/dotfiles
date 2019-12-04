

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

#TMOUT=1

# TRAPALRM() {
#    zle reset-prompt
#}

# path


test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

