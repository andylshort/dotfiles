# Enable completion
autoload -Uz compinit
compinit

zstyle ':completion:*' list-colors "$LS_COLORS"

# Enable colors
autoload -Uz colors
colors

# History
# (Also see .zshenv)
# - Don't store duplicates
setopt HIST_SAVE_NO_DUPS

# TODO: Enable this once I figure it out
# Vim mode
# - Enable vi-style key bindings
#bindkey -v
# - Make switching between modes faster
#export KEYTIMEOUT=1

# Aliases
source "$ZDOTDIR/aliases"

# Git integration
# - Enable the source control module
autoload -Uz vcs_info
# - Allow substitution of variables in the prompt
setopt prompt_subst
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true 
# - Configure style depending on the status of the branch
zstyle ':vcs_info:*' stagedstr ' +' 
zstyle ':vcs_info:*' unstagedstr ' !'

precmd() {
    vcs_info
    #print -P "%~ ${vcs_info_msg_0_}"
}

# Prompt
# %n - username
# %m - hostname
# %d - current directory (full path)
# %~ - current directory (relative to $HOME)
# %1~ - current directory (name only)
# %# - terminal char (% for regular, # for privileged)
PROMPT=$'%{${fg[yellow]}%}%n%{${reset_color}%} at %{%F{215}%}%m%{${reset_color}%} in %{%F{33}%}%~%{${reset_color}%}\n%# '

