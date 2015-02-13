#!/bin/sh

apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y
aptitude -r install linux-headers-$(uname -r)
apt-get install nvidia-xconfig nvidia-kernel-dkms
sed 's/quiet/quiet nouveau.modeset=0/g' -i /etc/default/grub
update-grub
nvidia-xconfig