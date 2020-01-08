# variables
export VISUAL=vim
export EDITOR=vim

export GREP_OPTIONS="--color=auto"

# Set CLICOLOR if you want Ansi Colors in iTerm2 
export CLICOLOR=1

# Set colors to match iTerm2 Terminal Colors
export TERM=xterm-256color

# history
[ -z "$HISTFILE" ] && HISTFILE=$HOME/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify
setopt inc_append_history
setopt share_history

# alias
alias ls="ls -G"
alias ..="cd .."
alias ...="cd ..; cd .."
alias ezsh="$EDITOR ~/.zshrc"
alias g="git"
alias ll="ls -la"
alias rzsh="source ~/.zshrc"

# prompt
autoload colors && colors
PROMPT="%n@%m %{$fg[green]%}[%~]%{$reset_color%}"$'\n'"\$ "

# path
export PATH="$HOME/bin:$PATH"
export PATH="/usr/local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

# iterm integrations
if [ "$(uname 2> /dev/null)" = "Darwin" ]; then
    test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
fi
