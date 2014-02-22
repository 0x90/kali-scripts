#!/bin/bash

. ask.sh

ask "Do you want to enable numlock on boot?" Y || exit 3

apt-get -y install numlockx
cp -n /etc/gdm3/Init/Default{,.bkup}
grep -q '/usr/bin/numlockx' /etc/gdm3/Init/Default || sed -i 's#exit 0#if [ -x /usr/bin/numlockx ]; then\n/usr/bin/numlockx on\nfi\nexit 0#' /etc/gdm3/Init/Default
