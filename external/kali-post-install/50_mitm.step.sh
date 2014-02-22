#!/bin/bash
. ask.sh

ask "Do you want install mitm tools??" Y || exit 3

# yamas.sh
apt-get install -y arpspoof ettercap-text-only sslstrip
wget http://comax.fr/yamas/bt5/yamas.sh -O /usr/bin/yamas
chmod +x /usr/bin/yamas

# parponera
git clone https://code.google.com/p/paraponera/ ~/develop/parponera
cd ~/develop/parponera
./install.sh

# haxorblox
# apt-get install -y hamster-sidejack ferret-sidejack dsniff gawk snarf ngrep
