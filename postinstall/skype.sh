#!/usr/bin/env bash
#
source ../helper/helper.sh

dpkg --add-architecture i386
apt-get update

cd /tmp
wget -O skype-install.deb http://www.skype.com/go/getskype-linux-deb
dpkg -i skype-install.deb

apt-get install gdebi
apt-get -f install

#
apt-get autoclean