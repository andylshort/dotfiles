# ${XDG_CONFIG_HOME}/zsh/conf.d/core.zsh

# ZSH-Specific Aliases

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

# Many terminals use Ctrl-s and Ctrl-q for flow control by default. This
# interferes with using Ctrl-r and Ctrl-s for history searching. Disable it.
stty stop undef