#!/usr/bin/env bash
# .bash_profile

# PATH for every login shell, interactive or not (e.g. `bash -lc cmd` over ssh): .bashrc
# stops early when non-interactive, and its own PATH loop skips entries already set here.
for d in "$HOME/bin" "$HOME/.local/bin"; do
    [[ -d $d && ":$PATH:" != *":$d:"* ]] && PATH="$d:$PATH"
done
export PATH

# shellcheck source=.bashrc
if [[ -f "$HOME/.bashrc" ]]; then
    source "$HOME/.bashrc"
fi
