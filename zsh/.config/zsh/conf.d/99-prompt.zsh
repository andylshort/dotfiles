# ${XDG_CONFIG_HOME}/zsh/conf.d/prompt.zsh

if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
fi