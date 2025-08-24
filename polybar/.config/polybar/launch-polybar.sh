#!/usr/bin/env bash

# Terminate already running bar instances
polybar-msg cmd quit

# Launch bar 'main'
echo "---" | tee -a /tmp/polybar-main.log
polybar main 2>&1 | tee -a /tmp/polybar-main.log & disown

echo "Bars launched..."
