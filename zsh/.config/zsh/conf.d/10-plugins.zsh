# ${XDG_CONFIG_HOME}/zsh/conf.d/10-plugins.zsh

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME/.git" ]]; then
    mkdir -p "$(dirname "$ZINIT_HOME")"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"


# `zinit ice wait lucid` delays plugin load until after prompt render
# Autosuggestions
zinit ice wait'0' lucid
zinit light 'zsh-users/zsh-autosuggestions'

# More ZSH Completions
zinit ice wait'0' lucid
zinit light 'zsh-users/zsh-completions'

# Syntax Highlighting
# IMPORTANT: This must always be the last loaded plugin
zinit ice wait'0' lucid
zinit light 'zsh-users/zsh-syntax-highlighting'