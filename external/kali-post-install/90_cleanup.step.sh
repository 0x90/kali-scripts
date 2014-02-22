#!/bin/bash

. ask.sh

apt-get install -y localepurge
apt-get -y autoremove
apt-get clean

localepurge

#history -c
#rm -f /root/.*_history

ask "Do you want to reboot?" N || exit

reboot
