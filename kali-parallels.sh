#!/bin/bash
# Parallels 9 + Kali Linux 1.0.6 (kernel 3.12)
#

echo "Preparing environment"
apt-get install -y gcc dkms make linux-headers-$(uname -r)

echo "Copying Parallels tools from CD"
cp -R /media/cdrom0 /tmp/

echo "Downloading patch file"
wget http://pastebin.com/raw.php?i=17fVAntV -O /tmp/parallels-tools-linux-3.12-prl-fs-9.0.23350.941886.patch

echo "Patching...."
cd /tmp/cdrom0/kmods
tar -xaf prl_mod.tar.gz
patch -p1 -d prl_fs < /tmp/parallels-tools-linux-3.12-prl-fs-9.0.23350.941886.patch
tar -czf prl_mod.tar.gz prl_eth prl_fs prl_fs_freeze prl_tg Makefile.kmods dkms.conf

echo "Launching install"
/tmp/cdrom0/install

