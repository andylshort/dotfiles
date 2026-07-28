# ${XDG_CONFIG_HOME}/zsh/conf.d/30-completion.zsh

autoload -Uz compinit

# Define explicit dump location
ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-$ZSH_VERSION"

# Ensure directory exists
[[ -d "${ZSH_COMPDUMP:h}" ]] || mkdir -p "${ZSH_COMPDUMP:h}"

# 1. If cache is older than 24h, rebuild it. Otherwise, use -C to skip all 1,050 compdef calls.
if [[ ! -f "$ZSH_COMPDUMP" || -n "$(find "$ZSH_COMPDUMP" -mtime +0 2>/dev/null)" ]]; then
    compinit -i -u -d "$ZSH_COMPDUMP"
else
    compinit -C -i -u -d "$ZSH_COMPDUMP"
fi

# 2. Compile the dump file to binary bytecode (.zwc) if needed
if [[ ! -f "${ZSH_COMPDUMP}.zwc" || "${ZSH_COMPDUMP}" -nt "${ZSH_COMPDUMP}.zwc" ]]; then
    zcompile "$ZSH_COMPDUMP"
fi

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}' # Case-insensitive
zstyle ':completion:*' menu select                     # Arrow-key selection menu
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Reverse through completion suggestions on Shift-Tab
bindkey '^[[Z' reverse-menu-complete