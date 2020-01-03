#!/bin/bash
# install zsh+prezto+powerline

# zsh
apt install zsh fontconfig rake -y

# screen
apt install screen tmux -y

# https://github.com/skwp/dotfiles
sh -c "`curl -fsSL https://raw.githubusercontent.com/skwp/dotfiles/master/install.sh `"

# colorls
gem install colorls
