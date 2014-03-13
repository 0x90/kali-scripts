#!/bin/sh

apt-get install gcc-arm-linux-gnueabi libc6-dev-armel-cross qemu git-core gnupg flex bison gperf \
 libesd0-dev build-essential zip curl libncurses5-dev zlib1g-dev libncurses5-dev gcc-multilib g++-multilib


if [ `getconf LONG_BIT` = "64" ]
then
    echo "64-bit OS detected install 32-bit libs"
    dpkg --add-architecture i386
    apt-get update -y
    apt-get install ia32-libs -y
fi

# Скачайте Linaro кросс-компилятор из нашего Git репозитория.
cd ~
mkdir -p arm-stuff/kernel/toolchains
cd arm-stuff/kernel/toolchains
git clone git://github.com/offensive-security/arm-eabi-linaro-4.6.2.git

#
export ARCH=arm
export CROSS_COMPILE=~/arm-stuff/kernel/toolchains/arm-eabi-linaro-4.6.2/bin/arm-eabi-
