#!/usr/bin/env bash

# ripgrep
if command -v rg > /dev/null; then
    alias grep='rg'
    # 'rgi' for case-insensitive
    alias rgi='rg -i'
fi

# fzf
if command -v fzf > /dev/null; then
    eval "$(fzf --bash)"
    
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
