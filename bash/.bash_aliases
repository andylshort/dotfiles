# .bash_aliases

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

# Other programs
alias g="git"
alias gpl="git pull --recurse-submodules"

# Reload bash configuration file to apply changes
alias rebash='source $HOME/.bashrc'
