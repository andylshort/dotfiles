# ${XDG_CONFIG_HOME}/zsh/conf.d/60-integrations.zsh

# Zoxide (Smarter 'cd')
# if command -v zoxide &> /dev/null; then
#     eval "$(zoxide init zsh)"
# fi

# fzf Setup & Keybindings
if command -v fzf &> /dev/null; then
    # Source fzf, disabling the Ctrl-r keybinding (use atuin instead)
    FZF_CTRL_R_COMMAND= FZF_ALT_C_COMMAND= source <(fzf --zsh)

    # Modern fzf preview defaults (uses 'eza' or 'ls' for directories, 'bat' or 'cat' for files)
    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --inline-info"

    # If I type a full query, and no matches, paste as command
    export FZF_CTRL_R_OPTS="--bind enter:accept-or-print-query"

    export FZF_DEFAULT_COMMAND="--with-shell='zsh -fc'"

    export FZF_TMUX=0
fi