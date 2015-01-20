#!/bin/bash
# http://www.blackmoreops.com/2014/02/11/install-amd-ati-proprietary-driver-fglrx-in-kali-linux-1-0-6-running-kernel-version-3-12-6/
# http://www.blackmoreops.com/2014/06/30/kali-linux-1-0-7-kernel-3-14-install-nvidia-driver-kernel-module-cuda-pyrit/

. helper.sh


nvidia_drivers(){
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

nvidia_drivers