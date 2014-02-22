#!/bin/bash
. ask.sh

ask "Do you want to install new dotfiles (tmux, aliases, initrc etc.?)" Y || exit 3

cp dotfiles/.* ~
