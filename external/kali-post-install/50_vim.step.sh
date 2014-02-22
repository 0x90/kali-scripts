#!/bin/bash
. ask.sh

ask "Do you want to install vim and some extras? (unfinished, maybe better you do it yourself)" N || exit 3

apt-get install -y vim vim-rails

# be careful with existing vim-config
mv ~/.vimrc ~/.vimrc.bak
mv ~/.vim ~/.vim.bak

mkdir -p ~/.vim/bundle
git clone git://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim

cp dotfiles/.vimrc ~/.vimrc
cp -R dotfiles/.vim/* ~/.vim/

mkdir -p ~/develop/powerline
git clone git://github.com/Lokaltog/powerline ~/develop/powerline
cd ~/develop/powerline
python setup.py install

mkdir ~/.config/powerline
cp -R ~/develop/powerline/powerline/config_files/* ~/.config/powerline

mkdir -p ~/.fonts/

wget https://github.com/Lokaltog/powerline-fonts/raw/master/InconsolataDz/Inconsolata-dz%20for%20Powerline.otf -O ~/.fonts/Inconsolata-dz\ for\ Powerline.otf
fc-cache -vf ~/.fonts

