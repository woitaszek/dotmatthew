#!/bin/bash

# 
# This script installs links for various dotfiles to the .matthew
# configuration file repository.
#


echo ".inputrc"
rm -f ~/.inputrc
ln -s  ~/.matthew/rc/inputrc ~/.inputrc

echo ".vimrc"
rm -f ~/.vimrc
ln -s  ~/.matthew/rc/vimrc ~/.vimrc

echo ".screenrc"
rm -f ~/.screenrc
ln -s  ~/.matthew/rc/screenrc ~/.screenrc

echo ".bashrc.global"
rm -f ~/.bashrc.global
ln -s ~/.matthew/bashrc/global.sh ~/.bashrc.global

echo ".bashrc"
rm -f ~/.bashrc
ln -s ~/.matthew/bashrc/bashrc ~/.bashrc

echo ".bashrc.local:"
echo "Remember to create a link to the proper file manually:"
echo "  $ rm -f ~/.bashrc.local"
echo "  $ ln -s ~/.matthew/bashrc/local_SYSTEM.sh .bashrc.local"
echo


