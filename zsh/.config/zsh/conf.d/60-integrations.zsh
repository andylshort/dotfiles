# ${XDG_CONFIG_HOME}/zsh/conf.d/60-integrations.zsh

# fzf Setup & Keybindings
if command -v fzf &> /dev/null; then
    # Source fzf, disabling the Ctrl-r (atuin does that) and Alt-c keybindings
    FZF_CTRL_R_COMMAND= FZF_ALT_C_COMMAND= source <(fzf --zsh)

    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --inline-info"

    # Use ripgrep (rg) as the backend for fzf to ignore .git/ and node_modules/
    if command -v rg &> /dev/null; then
        export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!{.git,node_modules}/*"'
    fi
fi