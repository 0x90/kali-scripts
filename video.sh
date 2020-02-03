#!/usr/bin/env bash
# Installation script for AMD/NVIDIA video drivers.

. helper.sh

# http://www.axozie.org/2014/09/install-amd-ati-proprietary-fglrx_8.html
install_ati_driver(){
    # Backup
    mv /etc/apt/sources.list /etc/apt/sources.list.bak

    # New sources file
    cp "files/etc/sources.list" /etc/apt/sources.list


    apt-get update -y
    apt-get install -y firmware-linux-nonfree amd-opencl-icd linux-headers-$(uname -r) fglrx-atieventsd fglrx-driver fglrx-control fglrx-modules-dkms -y
    aticonfig --initial -f
}

install_nvidia_driver(){
    apt_super_upgrade
    aptitude -r install linux-headers-$(uname -r)
    apt-get install -y nvidia-xconfig nvidia-kernel-dkms
    sed 's/quiet/quiet nouveau.modeset=0/g' -i /etc/default/grub
    update-grub
    nvidia-xconfig
}

install_nvidia_docker(){
    id=$(. /etc/os-release;echo $ID)
    version_id=$(. /etc/os-release;echo $VERSION_ID)
    distribution=$(. /etc/os-release;echo $ID$VERSION_ID)

    if [[ $id == 'kali' ]]; then
        distribution=ubuntu18.04
    fi

    curl -s -L https://nvidia.github.io/nvidia-container-runtime/gpgkey |sudo apt-key add -
    curl -s -L https://nvidia.github.io/nvidia-container-runtime/$distribution/nvidia-container-runtime.list | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-runtime.list
    sudo apt update && sudo apt -y install nvidia-container-toolkit
}


install_video_driver(){
    if ask "Install ATI/AMD driver fglrx?" N; then
        install_ati_driver
    fi

    if ask "Install NVIDIA driver nouveau?" N; then
        install_nvidia_driver
    fi
}

if [ "${0##*/}" = "video.sh" ]; then
    install_video_driver
fi
