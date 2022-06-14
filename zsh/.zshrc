trysource() { for f in "$@"; do source "$f" 2>/dev/null && return; done; }

# Load any preamble necessary
trysource $HOME/.zshrc.pre

# Aliases
alias ..="cd ..;"
alias mkdir="mkdir -p"
alias rzsh="source $HOME/.zshrc"

alias g="git"
alias ga="git ls-files -m -o --exclude-standard | fzf --print0 -m | xargs -0 -t -o git add"
alias gd="git ls-files -m -o --exclude-standard | fzf --print0 -m | xargs -0 -t -o git diff --patch-with-stat"
alias gc="git commit"
alias gp="git push"
alias gs='git status'

# Remote connection-specific settings
if [[ -n "$SSH_TTY" ]] || [[ -n "$SSH_CONNECTION" ]] || [[ -n "$SSH_CLIENT" ]]; then
  # Set the GPG input to the terminal, rather than open the GUI program
  export GPG_TTY=$(tty)
  export TERM=xterm-256color
fi

# Autocompletion
autoload -Uz compinit
compinit
_comp_options+=(globdots)

# Highlight on tab
zstyle ':completion:*' menu select

# History
setopt sharehistory extendedhistory histignorealldups histignorespace histreduceblanks
SAVEHIST=10000
HISTFILE="$HOME/.zsh_history"

# Prompt
autoload -U colors && colors
setopt prompt_subst
autoload -Uz add-zsh-hook vcs_info
# Enable checking for (un)staged changes, enabling use of %u and %c
zstyle ':vcs_info:*' check-for-changes true
# Set custom strs for an unstaged vcs repo changes (*) and staged changes (+)
zstyle ':vcs_info:*' unstagedstr ' *'
zstyle ':vcs_info:*' stagedstr ' +'
# Set the format of the Git information for vcs_info
zstyle ':vcs_info:git:*' formats       '(%b%u%c)'
zstyle ':vcs_info:git:*' actionformats '(%b|%a%u%c)'

function preexec_check() {
    preexec_called=true
}
function write_prompt() {
    local LAST_EXIT_CODE=$?
    PROMPT=''
    if [ "$preexec_called" = true ]; then
        if [ "$LAST_EXIT_CODE" -eq 0 ]; then
            PROMPT+="%{$fg_bold[green]%}✓%{$reset_color%} %F{243}%T%f"$'\n'
        else
            PROMPT+="%{$fg_bold[red]%}✗ ($?)%{$reset_color%} %F{243}%T%f"$'\n'
        fi
        unset preexec_called
    fi
    PROMPT+='%n@%M %F{cyan}%d%f'$'\n''\$ '

    # Add git repository information to RHS of prompt
    if [[ -n ${vcs_info_msg_0_} ]]; then
        # Colourise git branch info dependent on state
        GIT_STATUS=$(command git status --porcelain 2> /dev/null | tail -n 1)
        if [[ -n $GIT_STATUS ]]; then
            RPROMPT='%F{red}${vcs_info_msg_0_}%f'
        else
            RPROMPT='%F{green}${vcs_info_msg_0_}%f'
        fi
    else
        RPROMPT=""
    fi
}
add-zsh-hook preexec preexec_check
add-zsh-hook precmd vcs_info
add-zsh-hook precmd write_prompt

# Load machine-local changes
trysource $HOME/.zshrc.local
