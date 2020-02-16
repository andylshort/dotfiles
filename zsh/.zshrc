autoload -U colors && colors

# variables
export VISUAL="vim"
export EDITOR="vim"

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

autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^[[A" history-beginning-search-backward-end
bindkey "^[[B" history-beginning-search-forward-end

autoload -U compinit && compinit
autoload -U bashcompinit && bashcompinit

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
            echo "%F{green}($(git_branch_name)) "
        else
            echo "%F{red}(*$(git_branch_name)) "
        fi
    fi
}

# prompt
setopt prompt_subst
PROMPT='%(!.su.)%(?.%F{green}>.%F{red}>)%f '
RPROMPT='%{$fg[cyan]%}[%~] $(print_git_repo)%{$reset_color%}%n@%m'

# path
export PATH="$HOME/bin:$PATH"
export PATH="/usr/local/bin:$PATH"

[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
