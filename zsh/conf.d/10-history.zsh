# ${XDG_CONFIG_HOME}/zsh/conf.d/history.zsh

HISTFILE="$HOME/.zsh_history"
HISTSIZE=1000000
SAVEHIST=1000000
setopt SHARE_HISTORY          # Share history across sessions immediately
setopt HIST_IGNORE_ALL_DUPS   # Don't record duplicate entries
setopt HIST_IGNORE_SPACE      # Don't record commands starting with space
setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicate entries first when trimming
setopt HIST_FIND_NO_DUPS      # Do not display duplicates when searching history

# partial search through history on Up and Down keys
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down