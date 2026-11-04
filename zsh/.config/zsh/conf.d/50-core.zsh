# ${XDG_CONFIG_HOME}/zsh/conf.d/50-core.zsh

# Many terminals use Ctrl-s and Ctrl-q for flow control by default. This
# interferes with using Ctrl-r and Ctrl-s for history searching. Disable it.
stty stop undef

# Aliases
# - An alias ending in a space makes the next word alias-expanded too (e.g. sudo ll)
alias sudo='sudo '
alias xargs='xargs '

# - Colour
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ip='ip -color=auto'
(( $+commands[tree] )) && alias tree='tree -C'
export LESS='-R' # Keep colours when piping to less

# - Shortcuts
alias ll='ls -lah'
alias sc='systemctl'
alias ssc='sudo systemctl'
alias jc='journalctl'

# Functions
# - Sorted output when just listing the environment
env() {
    if (( $# == 0 )); then
        command env | sort
    else
        command env "$@"
    fi
}

mkcd() {
    mkdir -p -- "$1" && cd -- "$1"
}

reload() {
    source "$ZDOTDIR/.zshrc" && echo 'zsh configuration reloaded.'
}
