# ${XDG_CONFIG_HOME}/zsh/conf.d/core.zsh

# Aliases
# This will enable us to use aliases in sudo.
# (If alias finishes with a space or tab, the shell will check if the next command is also aliased.)
# Source: https://github.com/mayah/home/blob/master/.zsh/zshrc.d/alias.zsh
alias sudo='sudo '

# System
alias sc="systemctl"
alias ssc="sudo systemctl"
alias jc="journalctl"

# Colouring output
# Enable colorized ls output
alias ls='ls --color=auto'
alias ll='ls -lah --color=auto'

# Enable colorized grep family
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# Colorize diff, ip, and less
alias diff='diff --color=auto'
alias ip='ip -color=auto'
export LESS="-R" # Preserves colors when piping commands to less

# Config
alias reload="source ${ZDOTDIR:-$HOME}/.zshrc"


# Many terminals use Ctrl-s and Ctrl-q for flow control by default. This
# interferes with using Ctrl-r and Ctrl-s for history searching. Disable it.
stty stop undef