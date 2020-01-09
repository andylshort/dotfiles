autoload -U colors; colors

# variables
export VISUAL="vim"
export EDITOR="vim"

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

# functions
function git_branch_name() {
    ref=$(git symbolic-ref HEAD 2>/dev/null) || return
    echo "${ref#refs/heads/}"
}

function print_git_repo() {
    if $(! git status -s &> /dev/null)
    then
        echo ""
    else
        if [[ $(git status --porcelain) == "" ]]
        then
            echo "%{$fg[green]%}($(git_branch_name))"
        else
            echo "%{$fg[red]%}($(git_branch_name))*"
        fi
    fi
}

# prompt
setopt prompt_subst
PROMPT='%n@%m %{$fg[cyan]%}[%~] $(print_git_repo)%{$reset_color%}'$'\n''\$ '

# path
export PATH="$HOME/bin:$PATH"
export PATH="/usr/local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

# iterm integrations
if [ "$(uname 2> /dev/null)" = "Darwin" ]; then
    test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
fi
