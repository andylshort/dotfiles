# ~/.bashrc
# shellcheck disable=SC1090,SC1091
# Self-contained so it works on any machine on its own: `scp ~/.bashrc host:`.
# Uses whatever's installed (nvim/vim, fzf, git, starship) and skips the rest.
# Per-machine additions go in ~/.bashrc.{work,personal,local}.

[[ $- == *i* ]] || return

# Environment
for d in "$HOME/bin" "$HOME/.local/bin"; do
    [[ -d $d && ":$PATH:" != *":$d:"* ]] && PATH="$d:$PATH"
done
export PATH
if command -v nvim > /dev/null; then EDITOR=nvim
elif command -v vim > /dev/null; then EDITOR=vim
else EDITOR='vi'; fi
export EDITOR VISUAL=$EDITOR
export LESS=-R

shopt -s checkwinsize histappend cmdhist globstar 2> /dev/null
stty -ixon 2> /dev/null # Free Ctrl-S/Ctrl-Q from flow control

# History (moved to the XDG state dir by install.sh; plain ~/.bash_history elsewhere)
[[ -f ${XDG_STATE_HOME:-$HOME/.local/state}/bash/history ]] &&
    HISTFILE=${XDG_STATE_HOME:-$HOME/.local/state}/bash/history
HISTSIZE=1000000
HISTFILESIZE=1000000
HISTCONTROL=ignorespace:erasedups
HISTTIMEFORMAT='%F %T  '

# Readline: Tab cycles through matches, Up/Down search history by the typed prefix
bind 'set show-all-if-ambiguous on'
bind 'set completion-ignore-case on'
bind 'TAB: menu-complete'
bind '"\e[Z": menu-complete-backward'
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# Aliases
alias sudo='sudo ' # Expand aliases after sudo too
alias ls='ls --color=auto'
alias ll='ls -lah'
alias grep='grep --color=auto'
diff --color=auto /dev/null /dev/null 2> /dev/null && alias diff='diff --color=auto'
alias gs='git status' gd='git diff' ga='git add' gc='git commit' gp='git push'
mkcd() { mkdir -p -- "$1" && cd -- "$1" || return; }

# Completion (if the distro hasn't loaded it already) and fzf keybindings (fzf >= 0.48)
[[ -z ${BASH_COMPLETION_VERSINFO:-} && -r /usr/share/bash-completion/bash_completion ]] &&
    . /usr/share/bash-completion/bash_completion
command -v fzf > /dev/null && eval "$(fzf --bash 2> /dev/null)"

# Prompt: starship if installed, otherwise user@host:dir (branch) and a $ that turns
# red after a failed command
__prompt() {
    local status=$? branch colour=32
    ((status)) && colour=31
    branch=$(git symbolic-ref -q --short HEAD 2> /dev/null || git rev-parse -q --short HEAD 2> /dev/null)
    PS1="\[\e[1;34m\]\u@\h\[\e[0m\]:\[\e[1;36m\]\w\[\e[0m\]${branch:+ \[\e[35m\]($branch)\[\e[0m\]}\n\[\e[1;${colour}m\]\\\$\[\e[0m\] "
}
if command -v starship > /dev/null; then
    PROMPT_COMMAND="history -a"
    eval "$(starship init bash)"
else
    PROMPT_COMMAND="__prompt; history -a"
fi

for f in "$HOME"/.bashrc.{work,personal,local}; do
    [[ -f $f ]] && . "$f"
done
unset d f
