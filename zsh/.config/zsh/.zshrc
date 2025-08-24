# .zshrc

# Plugins
# * zsh-autosuggestions: Expanded and improved autosuggestions, similar to Fish
source $ZDOTDIR/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
# * zsh-syntax-highlighting: Syntax highlight command, similar to Fish
source $ZDOTDIR/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# * zsh-completions: Additional completion definitions
fpath=($ZDOTDIR/zsh-completions/src $fpath)

# Plugin configuration
# * zsh-autosuggestions
bindkey "^[[C" autosuggest-accept

# History settings
setopt HIST_SAVE_NO_DUPS
setopt INC_APPEND_HISTORY

# Colours
autoload -Uz colors
colors

# Autocompletion
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select

# Fuzzy finder
source <(fzf --zsh)

# Key bindings
# TIP: Use `sed -n l` and press keys to see their escaped key code
# * EMACS-style key bindings
bindkey -e
# * Ensure the following keys have their correct functionality
#   * Home and end
bindkey '^[[H' beginning-of-line
bindkey '^[[7~' beginning-of-line
bindkey '^[OH' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[8~' end-of-line
bindkey '^[OF' end-of-line
#   * Delete key
bindkey '^[[3~' delete-char
#   * Insert key
bindkey '^[[2~' quoted-insert

# Aliases
source $ZDOTDIR/.zsh_aliases

# Source control information
autoload -Uz vcs_info
zstyle ':vcs_info:git:*' formats 'on %b'
precmd() {
    vcs_info
}

# Prompt
setopt prompt_subst

function construct_prompt() {
    NEWLINE=$'\n'
    local my_prompt=""

    # Build in stages as some conditions need to be tested
    # * Indicator for last exit status
    my_prompt="%(?.%F{green}.%F{red})●%f "
    my_prompt+="%B%n%b %F{245}at%f %F{blue}%U%m%u%f %F{245}in%f %F{cyan}%~%f${NEWLINE}"
    # * Add git branch and information (if relevant)
	if [ -n "$vcs_info_msg_0_" ]; then
		my_prompt+="${vcs_info_msg_0_}${NEWLINE}"
	fi
    # * Character at end of prompt - `#` if privileged, `>` if not
    my_prompt+="%(!.#.>) "

    echo "$my_prompt"
}

# Single quotes here are important otherwise the function only runs once
PROMPT='$(construct_prompt)'
