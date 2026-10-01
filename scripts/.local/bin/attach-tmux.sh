#!/usr/bin/env bash
# Attach to the named session (default "testing"), creating it if needed.
exec tmux new-session -A -s "${1:-testing}"
