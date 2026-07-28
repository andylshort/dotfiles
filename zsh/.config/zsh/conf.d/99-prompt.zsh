# ${XDG_CONFIG_HOME}/zsh/conf.d/99-prompt.zsh

if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi