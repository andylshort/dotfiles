# ${XDG_CONFIG_HOME}/zsh/conf.d/20-history.zsh

HISTFILE="$HOME/.zsh_history"
HISTSIZE=1000000
SAVEHIST=1000000
setopt SHARE_HISTORY          # Share history across sessions immediately
setopt HIST_IGNORE_ALL_DUPS   # Don't record duplicate entries
setopt HIST_IGNORE_SPACE      # Don't record commands starting with space
setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicate entries first when trimming
setopt HIST_FIND_NO_DUPS      # Do not display duplicates when searching history

# Use atuin for shell history management
# Cache init so it doesn't run on each new shell
# If init.zsh after changes, run `rm ~/.cache/atuin/init.zsh`
ATUIN_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/atuin/init.zsh"
[[ -d "${ATUIN_CACHE:h}" ]] || mkdir -p "${ATUIN_CACHE:h}"

if [[ ! -f "$ATUIN_CACHE" ]]; then
    atuin init zsh > "$ATUIN_CACHE"
fi

source "$ATUIN_CACHE"