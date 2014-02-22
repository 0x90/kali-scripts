#!/bin/sh
# Based on http://wiki.openwrt.org/ru/doc/howto/build

# Dev tools
apt-get update
apt-get install -y subversion git-core git mercurial build-essential subversion libncurses5-dev zlib1g-dev gawk gcc-multilib flex \
ibncurses5-dev zlib1g-dev gawk flex gawk gcc-multilib flex gettext

# OpenWRT buildroot installation
mkdir ~/openwrt
cd openwrt
svn co svn://svn.openwrt.org/openwrt/trunk/
cd trunk

# Download and install feeds using feeds script. (optional)
./scripts/feeds update -a
./scripts/feeds install -a

#Use one of the following commands to check for missing packages on the system you want to build OpenWrt on:
make defconfig
make prereq
make menuconfig
