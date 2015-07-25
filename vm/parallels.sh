#!/usr/bin/env bash

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




parallels_tools(){
print_status "Mount Tools CD in virtual machine (Virtual Machine -> Install/Reinstall Parallels Tools)"
    pause

    # Download the patch from http://pastebin.com/8imsrmcN
    curl http://pastebin.com/raw.php?i=8imsrmcN > /tmp/parallels-tools-linux-3.12-prl-fs-9.0.23350.941886.patch

    # Make temporary copy of Parallels Tools, enter and patch it:
    #$ cp -R /media/$USER/Parallels\ Tools /tmp/
    #$ cd /tmp/Parallels\ Tools/kmods
    #$ tar -xaf prl_mod.tar.gz
    #$ patch -p1 -d prl_fs < parallels-tools-linux-3.12-prl-fs-9.0.23350.941886.patch
    #$ tar -czf prl_mod.tar.gz prl_eth prl_fs prl_fs_freeze prl_tg Makefile.kmods dkms.conf

    # Parallels 9 + Kali Linux 1.0.6 (kernel 3.12)
    mount -o exec /dev/hdb /media/Parallels\ Tools
    #cp -R /media/$USER/Parallels\ Tools /tmp/

    cp -R /media/cdrom0 /tmp/
    # cd /tmp/Parallels\ Tools/kmods
    cd /tmp/cdrom0/kmods

    # Patch from http://forum.parallels.com/showthread.php?294092-Fix-Patch-for-Parallel-Tools-9-0-23350-to-support-Linux-Kernel-3-12-%28Ubuntu-14-04%29
    tar -xaf prl_mod.tar.gz
    patch -p1 -d prl_fs < parallels-tools-linux-3.12-prl-fs-9.0.23350.941886.patch
    tar -czf prl_mod.tar.gz prl_eth prl_fs prl_fs_freeze prl_tg Makefile.kmods dkms.conf

    #4. Install normally:
    #$ sudo /tmp/Parallels\ Tools/install
    ../install
}