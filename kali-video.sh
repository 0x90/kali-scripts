#!/bin/bash
# http://www.blackmoreops.com/2014/02/11/install-amd-ati-proprietary-driver-fglrx-in-kali-linux-1-0-6-running-kernel-version-3-12-6/
# http://www.blackmoreops.com/2014/06/30/kali-linux-1-0-7-kernel-3-14-install-nvidia-driver-kernel-module-cuda-pyrit/

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
    echo "Step 1: Install Linux headers"
    aptitude -r install linux-headers-$(uname -r)
    echo "Step 2: Install NVIDIA Kernel"
    apt-get install nvidia-kernel-$(uname -r)

    echo "Step 3: Install NVIDIA Driver Kernel DKMS"
    aptitude install nvidia-kernel-dkms

    echo "Step 4: Install xconfig NVIDIA driver application"
    aptitude install nvidia-xconfig

    echo "Step 5: Generate xorg server configuration file"
    nvidia-xconfig
}

install_pyrit(){
    apt-get install nvidia-cuda-toolkit nvidia-opencl-icd

    echo "Step 3.a: Install Pyrit prerequisites"
    apt-get install python2.7-dev python2.7-libpcap libpcap-dev
    echo "Step 3.b: Remove existing installation of Pyrit"
    apt-get remove pyrit

    echo "Step 2: Download Pyrit and Cpyrit"
    cd /usr/src
    wget https://pyrit.googlecode.com/files/pyrit-0.4.0.tar.gz
    wget https://pyrit.googlecode.com/files/cpyrit-cuda-0.4.0.tar.gz
}

if ask "Do you want to install ATI fglrx?" Y; then
    fglrx
fi

if ask "Do you want to install NVidia, pyrit?" Y; then
    nvidia

    if ask "Do you want to install Pyrit?" Y; then
        install_pyrit
    fi
fi