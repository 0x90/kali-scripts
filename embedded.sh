#!/usr/bin/env bash
# http://lgogua.blogspot.ru/2013/07/all-goodies-repository-for-kali-linux.html
. helper.sh

install_avatar(){
    print_status "Install all build-dependencies"
    apt-get build-dep qemu llvm
    apt-get install build-essential subversion git gettext liblua5.1-dev libsdl1.2-dev libsigc++-2.0-dev binutils-dev python-docutils python-pygments nasm

    print_status "Get the source code from github"
    git clone https://github.com/eurecom-s3/s2e.git

    print_status "It will take some time to build..."
    mkdir build
    cd build
    make -j -f ../s2e/Makefile

    print_status "Installing Python3 and dependencies"
    sudo apt-get install -y python3 python3-pip

    print_status "Installing Avatar module from github"
    # http://llvm.org/devmtg/2014-02/slides/bruno-avatar.pdf
    sudo pip-3.2 install git+https://github.com/eurecom-s3/avatar-python.git#egg=avatar

    if ask "Do you want to install OpenOCD patched version?" Y; then
        # Install all build-dependencies
        apt-get build-dep openocd

        # Get the source code from github
        git clone git://git.code.sf.net/p/openocd/code openocd
        cd openocd
        git submodule init
        git submodule update

        # Configure OpenOCD (make sure to enable the driver for your adapter)
        autoreconf -i && ./configure

        # Build and install
        make -j && make install
    fi
}

install_binwalk(){
    # Install sasquatch to extract non-standard SquashFS images
    cd /tmp
    git clone https://github.com/devttys0/sasquatch
    cd sasquatch && make && sudo make install
    cd ..
    rm -rf /tmp/sasquatch

    # https://github.com/devttys0/binwalk/blob/master/INSTALL.md
    echo "Installing binwalk"
    apt-get install python-lzma libqt4-opengl python-opengl python-qt4 python-qt4-gl python-numpy python-scipy python-pip
    pip install pyqtgraph binwalk
}

install_emdebian(){
    # http://www.emdebian.org/crosstools.html
    print_status "Installing Emdebian, xapt"
    apt-get install emdebian-archive-keyring xapt -y
    echo "deb http://ftp.us.debian.org/debian/ squeeze main" > /etc/apt/sources.list.d/emdebian.list
    echo "deb http://www.emdebian.org/debian/ squeeze main" >> /etc/apt/sources.list.d/emdebian.list
    echo "deb http://www.emdebian.org/debian/ oldstable main" >> /etc/apt/sources.list/emdebian.list
    apt-get update -y

    echo "Installing GCC-4.4 for mips, mipsel"
    #apt-get install binutils-mipsel-linux-gnu binutils-mips-linux-gnu gcc-4.4-mips-linux-gnu gcc-4.4-mipsel-linux-gnu -y
	apt-get install linux-libc-dev-mipsel-cross libc6-mipsel-cross libc6-dev-mipsel-cross binutils-mipsel-linux-gnu gcc-4.4-mipsel-linux-gnu g++-4.4-mipsel-linux-gnu -y
	apt-get install linux-libc-dev-mips-cross libc6-mips-cross libc6-dev-mips-cross binutils-mips-linux-gnu gcc-4.4-mips-linux-gnu g++-4.4-mips-linux-gnu -y

    #echo deb http://www.emdebian.org/debian stable main >> /etc/apt/sources.list
    #wget http://http.us.debian.org/debian/pool/main/g/gmp/libgmp3c2_4.3.2+dfsg-1_amd64.deb -O /tmp/libgmp3c2_4.3.2+dfsg-1_amd64.deb
    #dpkg -i /tmp/libgmp3c2_4.3.2+dfsg-1_amd64.deb

    #print_status "Updating package list.."
    #apt-get update -y && apt-get upgrade -y

    #if ask "Install g++-4.4-arm-linux-gnueabi ?" Y; then
    #    apt-get install g++-4.4-arm-linux-gnueabi -y
    #fi
}

install_linaro_toolchains(){
    # http://elinux.org/Toolchains
    if ask "Install linaro toolchains?" N; then
        print_status "Installing Linaro toolchains..."
        mkdir -p /root/toolchains/arm
        cd /root/toolchains/arm
        git clone https://github.com/offensive-security/gcc-arm-linux-gnueabihf-4.7
        git clone https://github.com/offensive-security/gcc-arm-eabi-linaro-4.6.2

        echo "To use Linaro toolchains do this."
        echo "export ARCH=arm"
        echo "export CROSS_COMPILE=/root/toolchains/arm"
        echo "gcc something.c"
    fi
}

install_embedded(){
    if [ `getconf LONG_BIT` = "64" ] ; then
        if ask "64-bit OS detected. Installing 32-bit libs?" Y; then
            dpkg --add-architecture i386 && apt-get update -y && apt-get install ia32-libs -y
            success_check
        fi
    fi

    echo "Installing archivers"
    apt-get -y install mtd-utils gzip bzip2 tar arj lhasa p7zip p7zip-full cabextract openjdk-6-jdk cramfsprogs cramfsswap squashfs-tools zlib1g-dev liblzma-dev liblzo2-dev

    if ask "Install tool for onchip debugging and emulation" Y; then
        apt-get install -y skyeye openocd
    fi

    if ask "Install tools for serial port, FTDI libs?" Y; then
        apt-get install -y ftdi-eeprom libftdi1 python-ftdi minicom python-serial cutecom libftdi-dev python-ftdi -y
#        apt-get install -f libftdi1:i386 -y
    fi

    if ask "Install Emdebian crossdev?" Y; then
        install_emdebian
    fi

    if ask "Install binwalk and dependencies?" Y; then
        install_binwalk
    fi

    if ask "Do you want to install QEMU?" Y; then
        echo "Installing QEMU..."
        apt-get install qemu-system-arm qemu-system-mips qemu-system-common qemu-system-x86 qemu virt-manager virtinst -y
    fi

    if ask "Do you want to install Avatar?" N; then
        install_avatar
    fi

    if ask "Install Linaro toolchains?" N; then
        install_linaro_toolchains
    fi
}

install_embedded





