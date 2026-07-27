# ${XDG_CONFIG_HOME}/zsh/conf.d/integrations.zsh

# Zoxide (Smarter 'cd')
# if command -v zoxide &> /dev/null; then
#     eval "$(zoxide init zsh)"
# fi

# fzf Setup & Keybindings
if command -v fzf &> /dev/null; then
    eval "$(fzf --zsh)"

    # Modern fzf preview defaults (uses 'eza' or 'ls' for directories, 'bat' or 'cat' for files)
    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --inline-info"

    # If I type a full query, and no matches, paste as command
    export FZF_CTRL_R_OPTS="--bind enter:accept-or-print-query"

    export FZF_DEFAULT_COMMAND="--with-shell='zsh -fc'"

    export FZF_TMUX=0
fi