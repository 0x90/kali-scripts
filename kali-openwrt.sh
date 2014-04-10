#!/bin/bassh
. helper.sh
# Based on http://wiki.openwrt.org/ru/doc/howto/build

install_openwrt(){
    echo "Install dev tools for OpenWRT"
    apt-get update -y
    apt-get install -y subversion git-core git mercurial build-essential subversion libncurses5-dev zlib1g-dev gawk gcc-multilib flex libncurses5-dev zlib1g-dev gawk flex gawk gcc-multilib flex gettext

    echo "Creating OpenWRT directoy"
    mkdir ~/openwrt && cd ~/openwrt

    if ask "OpenWRT buildroot installation" Y; then
        wget http://downloads.openwrt.org/attitude_adjustment/12.09/ar71xx/generic/OpenWrt-ImageBuilder-ar71xx_generic-for-linux-i486.tar.bz2
        tar -xvjf OpenWrt-ImageBuilder-ar71xx_generic-for-linux-i486.tar.bz2
        cd OpenWrt-ImageBuilder-ar71xx_generic-for-linux-i486

        #TODO: Add build example
    fi

    # OpenWRT buildroot installation based on http://wiki.openwrt.org/ru/doc/howto/build
    if ask "Do you want to install OpenWRT buildroot from source" Y; then
        print_status "Cloning OpenWRT.."
        mkdir ~/openwrt
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
    fi
}