#!/usr/bin/env bash
# Installation script for AMD/NVIDIA video drivers.

. helper.sh

# http://www.axozie.org/2014/09/install-amd-ati-proprietary-fglrx_8.html
install_ati_driver(){
    # Backup
    mv /etc/apt/sources.list /etc/apt/sources.list.bak

    # New sources file
    cp "files/etc/sources.list" /etc/apt/sources.list
#    cat <<EOF > /etc/apt/sources.list
#    Official Repo Kali linux
#    deb http://http.kali.org/ /wheezy main contrib non-free
#    deb-src http://repo.kali.org/kali kali main non-free contrib
#    deb http://repo.kali.org/kali kali main/debian-installer
#    deb http://repo.kali.org/kali kali main contrib non-free
#    deb-src http://repo.kali.org/kali kali main contrib non-free
#    deb http://security.kali.org/kali-security kali/updates main contrib non-free
#    deb-src http://security.kali.org/kali-security kali/updates main contrib non-free
#    EOF

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