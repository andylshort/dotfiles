# ${XDG_CONFIG_HOME}/zsh/conf.d/history.zsh

# emacs-style keybindings
bindkey -e

# Ctrl-x Ctrl-e to edit current command in $EDITOR (from bash)
autoload edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

# Fix Insert/Delete/Home/End keys
typeset -A key
key[Home]=${terminfo[khome]}
key[End]=${terminfo[kend]}
key[Insert]=${terminfo[kich1]}
key[Delete]=${terminfo[kdch1]}
[[ -n "${key[Home]}"   ]]  && bindkey "${key[Home]}"   beginning-of-line
[[ -n "${key[End]}"    ]]  && bindkey "${key[End]}"    end-of-line
[[ -n "${key[Insert]}" ]]  && bindkey "${key[Insert]}" overwrite-mode
[[ -n "${key[Delete]}" ]]  && bindkey "${key[Delete]}" delete-char

# Set ANSI fallbacks
# - Home and End
bindkey '^[[H' beginning-of-line
bindkey '^[[1~' beginning-of-line
bindkey '^A' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[4~' end-of-line
bindkey '^E' end-of-line

# - Per word
bindkey "^[[1;3C" forward-word
bindkey "^[[1;5C" forward-word
bindkey "^[[1;3D" backward-word
bindkey "^[[1;5D" backward-word

# - Delete & Backspace 
bindkey '^[[3~' delete-char          # Standard Delete
bindkey '^?'    backward-delete-char # Backspace
bindkey "^[[3;3~" delete-word

# - Shift + Modifiers 
bindkey '^[[3;2~' kill-line          # Shift + Delete (erases line from cursor)
bindkey '^H'      backward-kill-word # Ctrl + Backspace

# Smarter paste
autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic