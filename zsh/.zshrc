# Source manjaro-zsh-configuration
#if [[ -e /usr/share/zsh/manjaro-zsh-config ]]; then
#  source /usr/share/zsh/manjaro-zsh-config
#fi
# Use manjaro zsh prompt
#if [[ -e /usr/share/zsh/manjaro-zsh-prompt ]]; then
#  source /usr/share/zsh/manjaro-zsh-prompt
#fi

source $HOME/.aliases


autoload -U compinit

# Enables you to go through the list and select one option
zstyle ':completion:*' menu select

# Case insensitive auto-completion
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# If the line has sudo or doas in it, then it tries to gain more access 
# while completing command options (-/--)
zstyle ':completion::complete:*' gain-privileges 1

compinit

# Show hidden files in the menu
_comp_options+=(globdots)

# Don't show . and .. in completion menu
zstyle ':completion:*' special-dirs false

# Enabling completion for command options (which start with -- or -)
zmodload zsh/complist


# Enable vim mode
bindkey -v
export KEYTIMEOUT=1

bindkey -v "^?" backward-delete-char
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char


# Change cursor shape for different vi modes.
function zle-keymap-select {
    case $KEYMAP in
        vicmd) echo -ne '\e[1 q';;      # block
        viins|main) echo -ne '\e[5 q';; # beam
    esac
}

zle -N zle-keymap-select

PROMPT='%n@%m %1~ %# '

# perform parameter expansion/command substitution in prompt
setopt PROMPT_SUBST

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

RPROMPT='${vim_mode}'
