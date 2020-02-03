#!/usr/bin/env bash
# Installation script for AMD/NVIDIA video drivers.

. helper.sh


install_ati_driver(){
    apt-get update -y
    apt-get install -y firmware-linux-nonfree amd-opencl-icd linux-headers-$(uname -r) fglrx-atieventsd fglrx-driver fglrx-control fglrx-modules-dkms -y
    aticonfig --initial -f
}

install_nvidia_cuda(){
    apt_super_upgrade
    aptitude -r install linux-headers-$(uname -r)
    apt-get install -y nvidia-xconfig nvidia-kernel-dkms
    apt-get install -y firmware-linux-nonfree nvidia-opencl-icd nvidia-cuda-toolkut
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
