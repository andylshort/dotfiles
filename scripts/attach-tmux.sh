#!/usr/bin/env bash
SESSION="$1"
if [[ -z "$SESSION" ]]; then
    SESSION="testing"
fi

if ! tmux has-session -t "$SESSION" 2> /dev/null; then
    tmux new-session -d -s "$SESSION"
fi
tmux attach -t "$SESSION"
