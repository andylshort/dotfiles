#!/bin/bash
# bash
ln -sfv $HOME/.dotfiles/.hushlogin $HOME/.hushlogin
ln -sfv $HOME/.dotfiles/.bashrc $HOME/.bashrc
ln -sfv $HOME/.dotfiles/.bash_profile $HOME/.bash_profile
ln -sfv $HOME/.dotfiles/.inputrc $HOME/.inputrc

# scripts and tools
ln -sfv $HOME/.dotfiles/bin $HOME/bin

# vim
ln -sfv $HOME/.dotfiles/.vim $HOME/.vim
ln -sfv $HOME/.dotfiles/.vimrc $HOME/.vimrc

# git
ln -sfv $HOME/.dotfiles/.gitconfig $HOME/.gitconfig

# gdb
ln -sfv $HOME/.dotfiles/.gdbinit $HOME/.gdbinit

if [[ `uname` == "Darwin" ]]
# load macOS-specific configuration
then
    # vscode
    ln -sfv $HOME/.dotfiles/vscode/settings.json $HOME/Library/Application\ Support/Code/User
    ln -sfv $HOME/.dotfiles/vscode/keybindings.json $HOME/Library/Application\ Support/Code/User
    ln -sfv $HOME/.dotfiles/vscode/snippets $HOME/Library/Application\ Support/Code/User
elif [[ `uname` == "Linux" ]]
# load linux-specific configuration
then
    # X
    ln -sfv $HOME/.dotfiles/.Xdefaults $HOME/.Xdefaults
    ln -sfv $HOME/.dotfiles/.Xresources $HOME/.Xresources

    # i3
    ln -sfv $HOME/.dotfiles/.config/i3 $HOME/.config/i3
    # rofi
    ln -sfv $HOME/.dotfiles/.config/rofi $HOME/.config/rofi

    # tmux
    ln -sfv $HOME/.dotfiles/.tmux.conf $HOME/.tmux.conf

    # mimeapps
    ln -sfv $HOME/.dotfiles/.config/mimeapps.list $HOME/.config/mimeapps.list

    # vscode
    ln -sfv $HOME/.dotfiles/vscode/settings.json $HOME/.config/Code/User
    ln -sfv $HOME/.dotfiles/vscode/keybindings.json $HOME/.config/Code/User
    ln -sfv $HOME/.dotfiles/vscode/snippets $HOME/.config/Code/User
fi