#!/usr/bin/env bash

# Wait for kwallet
kwallet-query -l kdewallet > /dev/null

for KEY in "$HOME"/.ssh/id_{rsa,ed25519}*; do
    # Skip if it's a public key
    [[ "$KEY" == *.pub ]] && continue
    # Skip if it's not a file (handles failed globs)
    [[ -f "$KEY" ]] || continue

    ssh-add -q "$KEY" </dev/null
done
