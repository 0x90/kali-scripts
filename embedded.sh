#!/usr/bin/env bash
# TODO: add https://github.com/pieceofsummer/squashfs-tools
# TODO: install from git
# https://github.com/devttys0/binwalk

. postinstall.sh

install_sasquatch(){
    print_status "Installing sasquatch dependencies"
    sudo apt-get install build-essential liblzma-dev liblzo2-dev zlib1g-dev
    
    cd /tmp
    print_status "Install sasquatch to extract non-standard SquashFS images"
    git clone https://github.com/devttys0/sasquatch
    cd sasquatch && make && sudo make install
    cd .. && rm -rf /tmp/sasquatch
}

install_binwalk(){
    print_status "Installing binwalk dependencies"
    apt-get install python-lzma libqt4-opengl python-opengl python-qt4 python-qt4-gl python-numpy python-scipy python-pip

    print_status "Installing binwalk"
    pip install pyqtgraph binwalk
}

install_emdebian(){
    # http://www.emdebian.org/crosstools.html
    print_status "Installing Emdebian, xapt"
    apt-get install emdebian-archive-keyring xapt -y
    apt_add_source emdebian
    cp -f "files/etc/emdebian.list" /etc/apt/sources.list.d/emdebian.list && apt-get update -y
#    echo "deb http://ftp.us.debian.org/debian/ squeeze main" > /etc/apt/sources.list.d/emdebian.list
#    echo "deb http://www.emdebian.org/debian/ squeeze main" >> /etc/apt/sources.list.d/emdebian.list
#    echo "deb http://www.emdebian.org/debian/ oldstable main" >> /etc/apt/sources.list/emdebian.list
    apt-get update -y

    print_status "Installing GCC-4.4 for mips, mipsel"
    #apt-get install binutils-mipsel-linux-gnu binutils-mips-linux-gnu gcc-4.4-mips-linux-gnu gcc-4.4-mipsel-linux-gnu -y
	apt-get install linux-libc-dev-mipsel-cross libc6-mipsel-cross libc6-dev-mipsel-cross binutils-mipsel-linux-gnu gcc-4.4-mipsel-linux-gnu g++-4.4-mipsel-linux-gnu -y
	apt-get install linux-libc-dev-mips-cross libc6-mips-cross libc6-dev-mips-cross binutils-mips-linux-gnu gcc-4.4-mips-linux-gnu g++-4.4-mips-linux-gnu -y

    #echo deb http://www.emdebian.org/debian stable main >> /etc/apt/sources.list
    #wget http://http.us.debian.org/debian/pool/main/g/gmp/libgmp3c2_4.3.2+dfsg-1_amd64.deb -O /tmp/libgmp3c2_4.3.2+dfsg-1_amd64.deb
    #dpkg -i /tmp/libgmp3c2_4.3.2+dfsg-1_amd64.deb
    #    apt-get install g++-4.4-arm-linux-gnueabi -y
}

install_linaro_toolchains(){
    # http://elinux.org/Toolchains
    print_status "Installing Linaro toolchains..."
    mkdir -p /root/toolchains/arm
    cd /root/toolchains/arm
    git clone https://github.com/offensive-security/gcc-arm-linux-gnueabihf-4.7
    git clone https://github.com/offensive-security/gcc-arm-eabi-linaro-4.6.2

    print_status "To use Linaro toolchains do this."
    print_status "export ARCH=arm"
    print_status "export CROSS_COMPILE=/root/toolchains/arm"
    print_status "gcc something.c"
}

install_embedded(){
    print_status "Installing archivers and other dependecies"
    install_archivers
    apt-get -y install mtd-utils openjdk-6-jdk cramfsprogs cramfsswap squashfs-tools

    if ask "Install Emdebian crossdev?" Y; then
        install_emdebian
    fi
    
    if ask "Install sasquatch?" Y; then
        install_sasquatch
    fi

    if ask "Install binwalk and dependencies?" Y; then
        install_binwalk
    fi

    if ask "Install Linaro toolchains?" N; then
        install_linaro_toolchains
    fi
}

if [ "${0##*/}" = "embedded.sh" ]; then
    install_embedded
fi





