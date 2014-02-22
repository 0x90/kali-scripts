#!/bin/bash
. ask.sh

ask "Do you want to install GMate (gedit modifications)?" Y || exit 3

apt-get install -y gedit

mkdir -p ~/develop

git clone git://github.com/gmate/gmate.git ~/develop/gmate
cd ~/develop/gmate
sh install.sh

