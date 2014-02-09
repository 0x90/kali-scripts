#!/bin/sh
# Parallels 9 + Kali Linux 1.0.6 (kernel 3.12)
#

# Prepare environment
apt-get update && apt-get install -y gcc dkms make linux-headers-$(uname -r)

#cp -R /media/$USER/Parallels\ Tools /tmp/
cp -R /media/cdrom0 /tmp/
# cd /tmp/Parallels\ Tools/kmods
cd /tmp/cdrom0/kmods

# Patching
tar -xaf prl_mod.tar.gz
patch -p1 -d prl_fs < parallels-tools-linux-3.12-prl-fs-9.0.23350.941886.patch
tar -czf prl_mod.tar.gz prl_eth prl_fs prl_fs_freeze prl_tg Makefile.kmods dkms.conf

# Install normally
../install && reboot
