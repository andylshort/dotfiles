# Source manjaro-zsh-configuration
#if [[ -e /usr/share/zsh/manjaro-zsh-config ]]; then
#  source /usr/share/zsh/manjaro-zsh-config
#fi
# Use manjaro zsh prompt
#if [[ -e /usr/share/zsh/manjaro-zsh-prompt ]]; then
#  source /usr/share/zsh/manjaro-zsh-prompt
#fi


trysource() {
    for f in "$@"; do
        if [ -f "$f" ]; then
            source "$f" 2>/dev/null && return;
        fi
    done;
}

# Load any preamble necessary
trysource $HOME/.zshrc.pre
trysource $HOME/.aliases

# Remote connection-specific settings
if [[ -n "$SSH_TTY" ]] || [[ -n "$SSH_CONNECTION" ]] || [[ -n "$SSH_CLIENT" ]]; then
  # Set the GPG input to the terminal, rather than open the GUI program
  export GPG_TTY=$(tty)
  export TERM=xterm-256color
fi

# Autocompletion
autoload -Uz compinit && compinit
# Show hidden files in the menu
_comp_options+=(globdots)

# Highlight options on tab
zstyle ':completion:*' menu select
# Case insensitive auto-completion
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# If the line has sudo or doas in it,
# then it tries to gain more access 
# while completing command options (-/--)
zstyle ':completion::complete:*' gain-privileges 1

# Don't show . and .. in completion menu
zstyle ':completion:*' special-dirs false

# Enabling completion for command options (which start with -- or -)
zmodload zsh/complist

# History
setopt sharehistory extendedhistory histignorealldups histignorespace histreduceblanks
SAVEHIST=10000
HISTFILE="$HOME/.zsh_history"

# Enable vim mode
bindkey -v
export KEYTIMEOUT=1

bindkey -v "^?" backward-delete-char
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char

# Prompt
autoload -U colors && colors
# perform parameter expansion/command substitution in prompt
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

# Change cursor shape for different vi modes.
function zle-keymap-select {
    case $KEYMAP in
        vicmd) echo -ne '\e[1 q';;      # block
        viins|main) echo -ne '\e[5 q';; # beam
    esac
}
zle -N zle-keymap-select

vim_ins_mode="[INSERT]"
vim_cmd_mode="[NORMAL]"
vim_mode=$vim_ins_mode

function zle-keymap-select {
    vim_mode="${${KEYMAP/vicmd/${vim_cmd_mode}}/(main|viins)/${vim_ins_mode}}"
    zle reset-prompt
}
zle -N zle-keymap-select

# Start zsh vi-mode in Normal mode
function zle-line-init() {
    zle -K vicmd;
}
zle -N zle-line-init

function zle-line-finish {
    vim_mode=$vim_ins_mode
}
zle -N zle-line-finish

function preexec_check() {
    preexec_called=true
}
function write_prompt() {
    local LAST_EXIT_CODE=$?
    PROMPT=''
    RPROMPT=''
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
            RPROMPT='${vim_mode} %F{red}${vcs_info_msg_0_}%f'
        else
            RPROMPT='${vim_mode} %F{green}${vcs_info_msg_0_}%f'
        fi
    else
        RPROMPT='${vim_mode}'
    fi
}
add-zsh-hook preexec preexec_check
add-zsh-hook precmd vcs_info
add-zsh-hook precmd write_prompt

# Load machine-local changes
trysource $HOME/.zshrc.local
