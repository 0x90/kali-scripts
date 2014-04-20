#!/bin/bash
# http://www.blackmoreops.com/2014/02/11/install-amd-ati-proprietary-driver-fglrx-in-kali-linux-1-0-6-running-kernel-version-3-12-6/

. helper.sh

fglrx(){
    #Step 1 (install gcc )
    apt-get install gcc

    #Step 2 (install Linux headers and recommended softwares)
    apt-get install firmware-linux-nonfree amd-opencl-icd linux-headers-$(uname -r)

    #Step 6 (install fglrx drivers and control)
    apt-get install dkms fglrx-atieventsd fglrx-driver fglrx-control fglrx-modules-dkms -y
    fglrxinfo
    fgl_glxgears

    aticonfig --initial -f
#    xorg.conf file will be located at /etc/X11 folder.
#
#    echo "Add radeon.modeset=0 in the end kernel command line in grub.cfg"
    #linux    /boot/vmlinuz-3.12-kali1-amd64 root=UUID=129deb3c-0edc-473b-b8e8-507f0f2dc3f9 ro initrd=/install/gtk/initrd.gz quiet radeon.modeset=0
}

nvidia(){
    echo "Add some code!"
    pause
}

fglrx