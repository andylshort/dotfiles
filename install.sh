#!/bin/bash

# git
stow git

# bash
stow bash
ln -sfv $HOME/.dotfiles/.hushlogin $HOME/.hushlogin
ln -sfv $HOME/.dotfiles/.inputrc $HOME/.inputrc

# zsh
stow zsh

# vim
# * vim-plug (https://github.com/junegunn/vim-plug)
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
stow vim

# neovim
stow nvim

# picom
stow picom

# i3-wm
stow i3

# tmux
stow tmux

# gdb
stow gdb

# mimeapps
stow mimeapps

# scripts and tools
ln -sfv $HOME/.dotfiles/bin $HOME/bin

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

    # rofi
    ln -sfv $HOME/.dotfiles/.config/rofi $HOME/.config/rofi

    # vscode
    ln -sfv $HOME/.dotfiles/vscode/settings.json $HOME/.config/Code/User
    ln -sfv $HOME/.dotfiles/vscode/keybindings.json $HOME/.config/Code/User
    ln -sfv $HOME/.dotfiles/vscode/snippets $HOME/.config/Code/User
fi
