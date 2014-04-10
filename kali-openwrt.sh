#!/bin/bash
# Based on http://wiki.openwrt.org/ru/doc/howto/build
#
. helper.sh

openwrt_prepare(){
    print_status "Installing development tools for OpenWRT.."
    #apt-get update -y
    apt-get install -y subversion git-core git mercurial build-essential subversion libncurses5-dev zlib1g-dev gawk gcc-multilib flex libncurses5-dev zlib1g-dev gawk flex gawk gcc-multilib flex gettext

    print_status "Creating OpenWRT directoy"
    mkdir ~/openwrt && cd ~/openwrt
}

openwrt_image_builder(){
    wget http://downloads.openwrt.org/attitude_adjustment/12.09/ar71xx/generic/OpenWrt-ImageBuilder-ar71xx_generic-for-linux-i486.tar.bz2
    tar -xvjf OpenWrt-ImageBuilder-ar71xx_generic-for-linux-i486.tar.bz2
    cd OpenWrt-ImageBuilder-ar71xx_generic-for-linux-i486

    #TODO: Add build example
}

openwrt_svn(){
    # OpenWRT buildroot installation based on http://wiki.openwrt.org/ru/doc/howto/build

    print_status "Cloning OpenWRT.."
    cd ~/openwrt
    svn co svn://svn.openwrt.org/openwrt/trunk/
    cd trunk

    if ask "Download and install feeds using feeds script. (optional)" Y ; then
        ./scripts/feeds update -a
        ./scripts/feeds install -a
    fi

    #Use one of the following commands to check for missing packages on the system you want to build OpenWrt on:
    if ask "Run OpenWRT configuration immidiately" N; then
        make defconfig
        make prereq
        make menuconfig
    fi
}

openwrt_git(){
    # Source from https://dev.openwrt.org/wiki/GetSource
    git clone git://git.openwrt.org/12.09/openwrt.git

    make menuconfig
    make
    scripts/flashing/flash.sh

    git clone git://git.openwrt.org/12.09/packages.git
}


install_openwrt(){
    openwrt_prepare

    if ask "OpenWRT Image builder" Y; then
        openwrt_image_builder
    fi

    if ask "Do you want to install OpenWRT buildroot from SVN" Y; then
        openwrt_svn
    fi

    if ask "Do you want to install OpenWRT buildroot from GIT" Y; then
        openwrt_git
    fi
}