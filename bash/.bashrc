# ~/.bashrc
# shellcheck disable=SC1090,SC1091
# Self-contained so it works on any machine on its own: `scp ~/.bashrc host:`.
# Uses whatever's installed (nvim/vim, fzf, bash-completion) and skips the rest.
# Per-machine additions go in ~/.bashrc.{work,personal,local}.

[[ $- == *i* ]] || return

# System defaults first, so everything below overrides them. On RHEL-family machines this is
# what sets up e.g. the `module` command in non-login shells like tmux panes (Debian's bash
# reads /etc/bash.bashrc by itself)
[[ -f /etc/bashrc ]] && . /etc/bashrc

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

# Prompt, as in zsh:  [ user@host ] dir (branch)   <- orange host badge over SSH
#                     $            <- red after a failed command
# The branch is read from .git/HEAD rather than by running git, so it's instant anywhere
__prompt() {
    local status=$? d=$PWD gitdir head branch
    while :; do
        if [[ -f $d/.git/HEAD ]]; then gitdir=$d/.git; break; fi
        if [[ -f $d/.git ]]; then
            read -r gitdir < "$d/.git"; gitdir=${gitdir#gitdir: }
            [[ $gitdir == /* ]] || gitdir=$d/$gitdir
            break
        fi
        [[ -z $d || $d == / ]] && break
        d=${d%/*}
    done
    [[ -n $gitdir ]] && read -r head < "$gitdir/HEAD" 2> /dev/null
    if [[ $head == 'ref: '* ]]; then branch=${head#ref: refs/heads/}; else branch=${head:0:7}; fi
    PS1=
    # Over SSH: user@host on an orange badge, matching the remote tmux bar
    [[ -n $SSH_CONNECTION ]] && PS1+='\[\e[1;30;48;5;215m\] \u@\h \[\e[0m\] '
    PS1+='\[\e[1;36m\]\w\[\e[0m\]'
    [[ -n $branch ]] && PS1+=" \[\e[35m\]($branch)\[\e[0m\]"
    PS1+="\n\[\e[1;$((status ? 31 : 32))m\]\\\$\[\e[0m\] "
}
PROMPT_COMMAND="__prompt; history -a"

for f in "$HOME"/.bashrc.{work,personal,local}; do
    [[ -f $f ]] && . "$f"
done
unset d f
