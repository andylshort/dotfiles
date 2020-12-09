[[ -r "$HOME/.bashrc.pre" ]] && source "$HOME/.bashrc.pre"

# history
export HISTTIMEFORMAT="%F %T "

# aliases
alias g="git"

[[ -r "$HOME/.bashrc.local" ]] && source "$HOME/.bashrc.local"
