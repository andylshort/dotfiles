#!/usr/bin/env zsh

# Uncomment to profile speed
# zmodload zsh/zprof

# emacs keybindings (for now...)
bindkey -e

# --- 1. Environment Variables ---
export PATH="$HOME/.local/bin:$PATH"
export EDITOR="vim"
export VISUAL="vim"
export BROWSER="firefox"

# --- 2. History Settings ---
HISTFILE="$HOME/.zsh_history"
HISTSIZE=1000000
SAVEHIST=1000000
setopt SHARE_HISTORY          # Share history across sessions immediately
setopt HIST_IGNORE_ALL_DUPS   # Don't record duplicate entries
setopt HIST_IGNORE_SPACE      # Don't record commands starting with space
setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicate entries first when trimming
setopt HIST_FIND_NO_DUPS      # Do not display duplicates when searching history

# --- 3. Plugin Manager (Zinit) ---
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME/.git" ]]; then
    mkdir -p "$(dirname "$ZINIT_HOME")"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"

# --- 4. Completion System ---
autoload -Uz compinit

# Define explicit dump location
ZSH_COMPDUMP="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump-$ZSH_VERSION"

# Ensure directory exists
[[ -d "${ZSH_COMPDUMP:h}" ]] || mkdir -p "${ZSH_COMPDUMP:h}"

# 1. If cache is older than 24h, rebuild it. Otherwise, use -C to skip all 1,050 compdef calls.
if [[ -n ${ZSH_COMPDUMP}(#qN.mh+24) ]]; then
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

# --- 5. Interactive Integrations (fzf, zoxide, starship) ---

# Zoxide (Smarter 'cd')
# if command -v zoxide &> /dev/null; then
#     eval "$(zoxide init zsh)"
# fi

# fzf Setup & Keybindings
if command -v fzf &> /dev/null; then
    eval "$(fzf --zsh)"

    # Modern fzf preview defaults (uses 'eza' or 'ls' for directories, 'bat' or 'cat' for files)
    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --inline-info"

    # If I type a full query, and no matches, paste as command
    export FZF_CTRL_R_OPTS="--bind enter:accept-or-print-query"
fi

# --- 6. Plugins (Loaded via Zinit) ---
# `zinit ice wait lucid` delays plugin load until after prompt render
# Autosuggestions
zinit ice wait'0' lucid
zinit light 'zsh-users/zsh-autosuggestions'

# History Substring Search
zinit load 'zsh-users/zsh-history-substring-search'
zinit ice wait atload'_history_substring_search_config'

# More ZSH Completions
zinit ice wait'0' lucid
zinit light 'zsh-users/zsh-completions'

# Syntax Highlighting
# IMPORTANT: This must always be the last loaded plugin
zinit ice wait'0' lucid
zinit light 'zsh-users/zsh-syntax-highlighting'

# --- 7. Prompt (Rendered Last) ---
if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi

# --- 8. Aliases ---
# Git
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"
alias gfo="git fetch origin"
alias grb="git rebase"
alias grbm="git rebase origin/master"

# Config
alias reload="source $HOME/.zshrc"

# --- 9. Keybindings ---
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Reverse through completion suggestions on Shift-Tab
bindkey '^[[Z' reverse-menu-complete

# Ctrl-x Ctrl-e to edit current command in $EDITOR (from bash)
autoload edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

# Fix Insert/Delete/Home/End keys
typeset -A key
key[Home]=${terminfo[khome]}
key[End]=${terminfo[kend]}
key[Insert]=${terminfo[kich1]}
key[Delete]=${terminfo[kdch1]}
[[ -n "${key[Home]}"   ]]  && bindkey "${key[Home]}"   beginning-of-line
[[ -n "${key[End]}"    ]]  && bindkey "${key[End]}"    end-of-line
[[ -n "${key[Insert]}" ]]  && bindkey "${key[Insert]}" overwrite-mode
[[ -n "${key[Delete]}" ]]  && bindkey "${key[Delete]}" delete-char

# Set ANSI fallbacks
# - Home and End
bindkey '^[[H' beginning-of-line
bindkey '^[[1~' beginning-of-line
bindkey '^A' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[4~' end-of-line
bindkey '^E' end-of-line

# - Delete & Backspace 
bindkey '^[[3~' delete-char          # Standard Delete
bindkey '^?'    backward-delete-char # Backspace

# - Shift + Modifiers 
bindkey '^[[3;2~' kill-line          # Shift + Delete (erases line from cursor)
bindkey '^H'      backward-kill-word # Ctrl + Backspace


# ---- 10. Misc ----
# Many terminals use Ctrl-s and Ctrl-q for flow control by default. This
# interferes with using Ctrl-r and Ctrl-s for history searching. Disable it.
stty stop undef

# ---- XX: Local Override ---
if [[ -f "${HOME}/.zshrc.work" ]]; then
    source "${HOME}/.zshrc.work"
fi

# Uncomment to profile speed
# zprof
