#!/usr/bin/env bash
# History

# - History file location
export HISTFILE="$HOME/.bash_history"

# - Add time and date information toeach command
export HISTTIMEFORMAT='%F %T - '

# - Save a lot of history (because you never know)
export HISTSIZE=100000000
export HISTFILESIZE=100000000

# - Ignore commands starting with space
# - Erase successive duplicates
# (Non-immediate duplicates provide detail and actual history.)
export HISTCONTROL=ignorespace:erasedups

# - Commands and patterns to exclude from inclusion to the history
export HISTIGNORE="ls:ll:clear:history:exit:pwd:top:reload"

# - Append to history instead of overwrite
shopt -s histappend

# - Rewrite multi-line commands into a single line
shopt -s cmdhist

# - Append command to history immediately 
# - Clear the history
# - Then re-read to get up-to-date history
export PROMPT_COMMAND="LAST_EXIT=\$?; history -a; history -c; history -r; $PROMPT_COMMAND"
