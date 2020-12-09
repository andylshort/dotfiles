[[ -r "$HOME/.zshrc.pre" ]] && source "$HOME/.zshrc.pre"

autoload -U colors && colors

# variables
export VISUAL="vim"
export EDITOR="$VISUAL"

if [ -n "$SSH_TTY" ] || [ -n "$SSH_CONNECTION"] || [ -n "$SSH_CLIENT" ]; then
    export GPG_TTY=$(tty)
    export TERM=xterm-256color
fi

# history
[[ -z "$HISTFILE" ]] && HISTFILE=$HOME/.zsh_history
HISTSIZE=10000000
SAVEHIST=10000000
setopt extended_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_verify
setopt hist_reduce_blanks
setopt inc_append_history
setopt share_history

# setopt extended_glob

# alias
alias ls="ls -G"
alias ..="cd .."
alias ...="cd ..; cd .."
alias ezsh="$EDITOR ~/.zshrc && source ~/.zshrc"
alias rzsh="source ~/.zshrc"
alias g="git"
alias ll="ls -la"
alias mkdir="mkdir -p"

autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "$key[Up]" history-beginning-search-backward-end
bindkey "^[[A" history-beginning-search-backward-end
bindkey "$key[Down]" history-beginning-search-forward-end
bindkey "^[[B" history-beginning-search-forward-end

autoload -U compinit && compinit
autoload -U bashcompinit && bashcompinit
zstyle ':completion:*' menu select
zmodload zsh/complist

bindkey -M menuselect '\e' send-break

# keybindings
bindkey '^[[H' beginning-of-line
bindkey '^[[E' end-of-line
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

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
            echo "%F{green}⊻ $(git_branch_name)%f"
        else
            echo "%F{red}⊻ $(git_branch_name)*%f"
        fi
    fi
}

function mcd() {
    mkdir -p -- "$@" && cd -- "$_";
}

function env() {
    command env $@ | sort;
}

function shrink_path() {
    setopt localoptions
    setopt rc_quotes null_glob

    typeset -i lastfull=1
    typeset -i short=1
    typeset -i tilde=1
    typeset -i named=0

    typeset -a tree expn
    typeset result part dir=${1-$PWD}
    typeset -i i

    [[ -d $dir ]] || return 0

    if (( named )) {
        for part in ${(k)nameddirs}; {
            [[ $dir == ${nameddirs[$part]}(/*|) ]] && dir=${dir/${nameddirs[$part]}/\~$part}
        }
    }
    (( tilde )) && dir=${dir/$HOME/\~}
    tree=(${(s:/:)dir})
    (
        unfunction chpwd 2> /dev/null
        if [[ $tree[1] == \~* ]] {
            cd ${~tree[1]}
            result=$tree[1]
            shift tree
        } else {
            cd /
        }
        for dir in $tree; {
            if (( lastfull && $#tree == 1 )) {
                result+="/$tree"
                break
            }
            expn=(a b)
            part=''
            i=0
            until [[ (( ${#expn} == 1 )) || $dir = $expn || $i -gt 99 ]]  do
                (( i++ ))
                part+=$dir[$i]
                expn=($(echo ${part}*(-/)))
                (( short )) && break
            done
            result+="/$part"
            cd $dir
            shift tree
        }
        echo ${result:-/}
    )
}

function change_filetype_for_all {
    readonly old=${1:?"Must specify the old filetype."}
    readonly new=${2:?"Must specify the new filetype."}
    a=(*$old)
    for file in "${a[@]}"
    do
        echo "$(basename $file $old)""$new"
    done
}

# prompt
setopt prompt_subst
PROMPT='%(?.%F{green}.%F{red})%(?.✔.✘)%f %F{008}at %T%f'$'\n''[%n@%m:%F{cyan}$(shrink_path)%f] $(print_git_repo)'$'\n''%(!.su.)≫ '

# path
export PATH="$HOME/bin:$PATH"
export PATH="/usr/local/bin:$PATH"

# local .zshrc config (machine-specific)
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

# vi: ft=sh
