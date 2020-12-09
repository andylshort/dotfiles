#!/bin/bash
# only do what you know to do, don't be too smart

# zsh
ln -sfv $HOME/.dotfiles/zsh/.hushlogin $HOME/.hushlogin
ln -sfv $HOME/.dotfiles/zsh/.zshrc $HOME/.zshrc

# bash
ln -sfv $HOME/.dotfiles/bash/.bashrc $HOME/.bashrc
ln -sfv $HOME/.dotfiles/bash/.bash_profile $HOME/.bash_profile
ln -sfv $HOME/.dotfiles/bash/.profile $HOME/.profile

# scripts and tools
ln -sfv $HOME/.dotfiles/bin $HOME/bin

# vim
ln -sfv $HOME/.dotfiles/vim/.vim $HOME/.vim
ln -sfv $HOME/.dotfiles/vim/.vimrc $HOME/.vimrc

# git
ln -sfv $HOME/.dotfiles/git/.gitconfig $HOME/.gitconfig

#gdb
ln -sfv $HOME/.dotfiles/gdb/.gdbinit $HOME/.gdbinit


if [[ `uname` == "Darwin" ]]
then
    # load macOS-specific configuration

    # vscode
    ln -sfv $HOME/.dotfiles/vscode/settings.json $HOME/Library/Application\ Support/Code/User
    ln -sfv $HOME/.dotfiles/vscode/keybindings.json $HOME/Library/Application\ Support/Code/User
    ln -sfv $HOME/.dotfiles/vscode/snippets $HOME/Library/Application\ Support/Code/User
elif [[ `uname` == "Linux" ]]
then
    # load linux-specific configuration

    # X
    ln -sfv $HOME/.dotfiles/x/.Xdefaults $HOME/.Xdefaults
    ln -sfv $HOME/.dotfiles/x/.Xresources $HOME/.Xresources

    # i3 and rofi
    ln -sfv $HOME/.dotfiles/.config/i3 $HOME/.config/i3
    ln -sfv $HOME/.dotfiles/.config/rofi $HOME/.config/rofi

    # tmux
    ln -sfv $HOME/.dotfiles/tmux/.tmux.conf $HOME/.tmux.conf

    # mimeapps
    ln -sfv $HOME/.dotfiles/.config/mimeapps.list $HOME/.config/mimeapps.list

    # vscode
    ln -sfv $HOME/.dotfiles/vscode/settings.json $HOME/.config/Code/User
    ln -sfv $HOME/.dotfiles/vscode/keybindings.json $HOME/.config/Code/User
    ln -sfv $HOME/.dotfiles/vscode/snippets $HOME/.config/Code/User
fi
