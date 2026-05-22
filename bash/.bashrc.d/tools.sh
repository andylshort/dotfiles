#!/usr/bin/env bash

# bat (or batcat)
if command -v batcat > /dev/null; then
    # Debian/Ubuntu uses 'batcat', others use 'bat'
    alias cat='batcat --paging=never'
    export PAGER='batcat'
elif command -v bat > /dev/null; then
    alias cat='bat --paging=never'
    export PAGER='bat'
fi

# eza
if command -v eza > /dev/null; then
    alias ls='eza'
fi

# ripgrep
if command -v rg > /dev/null; then
    alias grep='rg'
    # 'rgi' for case-insensitive
    alias rgi='rg -i'
fi

# fzf
if command -v fzf > /dev/null; then
    # Load fzf completions and keybindings if they exist in standard locations
    [ -f /usr/share/doc/fzf/examples/key-bindings.bash ] && source /usr/share/doc/fzf/examples/key-bindings.bash
    [ -f /usr/share/doc/fzf/examples/completion.bash ] && source /usr/share/doc/fzf/examples/completion.bash
    
    # Use ripgrep (rg) as the backend for fzf to ignore .git/ and node_modules/
    if command -v rg >/dev/null; then
        export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!{.git,node_modules}/*"'
    fi

    # Integration with tmux (if available and active)
    if [[ -n "$TMUX" ]]; then
        export FZF_TMUX=1
        export FZF_TMUX_OPTS="-p 80%,60%"
    fi
fi

# fd - replaces find
if command -v fd > /dev/null; then
    alias find='fd'
fi