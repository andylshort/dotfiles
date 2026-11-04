# ${ZDOTDIR}/.zshrc
# Extras (plugins, atuin, fzf) load only if installed, and nothing here touches the
# network, so this works and starts quickly on any machine.

# History
HISTFILE="$XDG_STATE_HOME/zsh/history"
[[ -d ${HISTFILE:h} ]] || mkdir -p ${HISTFILE:h}
HISTSIZE=1000000 SAVEHIST=1000000
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE HIST_EXPIRE_DUPS_FIRST HIST_FIND_NO_DUPS

# Completion: the dump is rebuilt at most daily; otherwise -C skips the slow checks
fpath=("$XDG_DATA_HOME/zsh/completions" $fpath)
autoload -Uz compinit
() {
    local dump="$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"
    local -a fresh=($dump(N.mh-24))
    [[ -d ${dump:h} ]] || mkdir -p ${dump:h}
    if (( $#fresh )); then compinit -C -d $dump; else compinit -i -d $dump; fi
    [[ $dump.zwc -nt $dump ]] || zcompile $dump # Compiled dump loads faster
}
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' # Case-insensitive
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Keybindings: emacs-style, plus what terminals send for Home/End/Delete/Ctrl-arrows
bindkey -e
autoload -Uz edit-command-line && zle -N edit-command-line
bindkey '^x^e' edit-command-line # Edit the command in $EDITOR
bindkey '^[[Z' reverse-menu-complete
for k v in '^[[H' beginning-of-line '^[[1~' beginning-of-line '^[[F' end-of-line \
    '^[[4~' end-of-line '^[[3~' delete-char '^[[3;3~' delete-word '^[[3;2~' kill-line \
    '^[[1;3C' forward-word '^[[1;5C' forward-word '^[[1;3D' backward-word \
    '^[[1;5D' backward-word '^H' backward-kill-word; do
    bindkey $k $v
done
unset k v
[[ -n ${terminfo[khome]} ]] && bindkey ${terminfo[khome]} beginning-of-line
[[ -n ${terminfo[kend]} ]] && bindkey ${terminfo[kend]} end-of-line
autoload -Uz bracketed-paste-magic && zle -N bracketed-paste bracketed-paste-magic
[[ -t 0 ]] && stty stop undef # Free Ctrl-S from flow control

# Aliases and functions
alias sudo='sudo ' xargs='xargs ' # Expand aliases after these too (sudo ll)
alias ls='ls --color=auto' grep='grep --color=auto' diff='diff --color=auto' ip='ip -color=auto'
(( $+commands[tree] )) && alias tree='tree -C'
export LESS='-R'
alias ll='ls -lah' sc='systemctl' ssc='sudo systemctl' jc='journalctl'
alias gs='git status' gd='git diff' ga='git add' gau='git add -u' gc='git commit'
alias gp='git push' gpf='git push --force-with-lease' gco='git checkout' gsw='git switch'
alias gf='git fetch --recurse-submodules' gfa='git fetch --all --recurse-submodules'
alias gfo='git fetch origin --recurse-submodules' grb='git rebase' grbm='git rebase origin/master'
env() { if (( $# )); then command env "$@"; else command env | sort; fi; } # Sorted listing
mkcd() { mkdir -p -- "$1" && cd -- "$1"; }
reload() { source "$ZDOTDIR/.zshrc" && echo 'zsh configuration reloaded.'; }

# Optional tools. Their init scripts are cached and regenerated when the tool is updated,
# saving a process per shell
_cached_init() {
    local cache="$XDG_CACHE_HOME/zsh/$1-init.zsh"
    [[ $cache -nt $commands[$1] ]] || "$@" >| $cache
    source $cache
}
if (( $+commands[fzf] )); then
    FZF_CTRL_R_COMMAND= FZF_ALT_C_COMMAND= # Ctrl-R is atuin's
    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --inline-info"
    (( $+commands[rg] )) && export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!{.git,node_modules}/*"'
    _cached_init fzf --zsh
fi
(( $+commands[atuin] )) && _cached_init atuin init zsh
# Plugins (cloned by install.sh); syntax highlighting must load last
for p in zsh-autosuggestions zsh-syntax-highlighting; do
    [[ -f $XDG_DATA_HOME/zsh/plugins/$p/$p.zsh ]] && source $XDG_DATA_HOME/zsh/plugins/$p/$p.zsh
done
unset p

# Prompt:  [ user@host ] dir (branch) [took 12s]   <- orange host badge over SSH
#          $            <- red after a failed command
# The branch is read straight from .git/HEAD rather than by running git, so the prompt
# stays instant in huge repos and on slow filesystems
zmodload zsh/datetime # EPOCHSECONDS
autoload -Uz add-zsh-hook
_prompt_branch() {
    local d=$PWD gitdir head
    REPLY=
    while true; do
        if [[ -f $d/.git/HEAD ]]; then gitdir=$d/.git; break; fi
        if [[ -f $d/.git ]]; then # Worktree or submodule: .git is a "gitdir: <path>" file
            read -r gitdir < $d/.git; gitdir=${gitdir#gitdir: }
            [[ $gitdir == /* ]] || gitdir=$d/$gitdir
            break
        fi
        [[ $d == / ]] && return
        d=${d:h}
    done
    read -r head < $gitdir/HEAD 2> /dev/null || return
    if [[ $head == 'ref: '* ]]; then REPLY=${head#ref: refs/heads/}; else REPLY=${head[1,7]}; fi
}
_prompt_preexec() { _prompt_start=$EPOCHSECONDS; }
_prompt_precmd() {
    local secs=$(( _prompt_start ? EPOCHSECONDS - _prompt_start : 0 ))
    _prompt_start=0
    (( _prompt_shown++ )) && print # Blank line between commands
    PROMPT=
    # Over SSH: user@host on an orange badge, matching the remote tmux bar
    [[ -n $SSH_CONNECTION ]] && PROMPT+='%B%K{215}%F{black} %n@%m %f%k%b '
    PROMPT+='%B%F{cyan}%~%f%b'
    _prompt_branch
    [[ -n $REPLY ]] && PROMPT+=" %F{magenta}(${REPLY//\%/%%})%f"
    if (( secs >= 60 )); then PROMPT+=" %F{yellow}took $(( secs / 60 ))m$(( secs % 60 ))s%f"
    elif (( secs >= 3 )); then PROMPT+=" %F{yellow}took ${secs}s%f"; fi
    PROMPT+=$'\n%B%(?.%F{green}.%F{red})$%f%b '
}
add-zsh-hook preexec _prompt_preexec
add-zsh-hook precmd _prompt_precmd

# Per-machine additions
for f in $HOME/.zshrc.{work,personal,local}(N); do source $f; done
unset f
