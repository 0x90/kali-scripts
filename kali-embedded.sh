#!/bin/bash
#TODO: add multiple repo support
# http://lgogua.blogspot.ru/2013/07/all-goodies-repository-for-kali-linux.html
. helper.sh


install_embedded(){
    if [ `getconf LONG_BIT` = "64" ] ; then
        if ask "64-bit OS detected. Installing 32-bit libs?" Y; then
            dpkg --add-architecture i386 && apt-get update -y && apt-get install ia32-libs -y
            success_check
        fi
    fi

    if ask "Install tool for onchip debugging and emulation" Y; then
        apt-get install -y skyeye openocd
    fi

    if ask "Install tools for serial port?" Y; then
        apt-get install -y ftdi-eeprom libftdi1 python-ftdi minicom python-serial cutecom
    fi

    if ask "Do you want to install Avatar?" Y; then
        print_status "Install all build-dependencies"
        sudo apt-get build-dep qemu llvm
        sudo apt-get install build-essential subversion git gettext liblua5.1-dev libsdl1.2-dev libsigc++-2.0-dev binutils-dev python-docutils python-pygments nasm

        print_status "Get the source code from github"
        git clone https://github.com/eurecom-s3/s2e.git

        print_status "It will take some time to build..."
        mkdir build
        cd build
        make -j -f ../s2e/Makefile


        print_status "Installing Python3 and dependencies"
        sudo apt-get install python3 python3-pip

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
            autoreconf -i
            ./configure

            # Build and install
            make -j
            make install
        fi
    fi

    if ask "Do you want to install QEMU?" Y; then
        apt-get install qemu-system-arm qemu-system-mips qemu-system-common qemu-system-x86
    fi

    # http://elinux.org/Toolchains
    if ask "Install linaro toolchains?" Y; then
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

    # https://www.embtoolkit.org/userguide.html#quick_start_guide
    if ask "Install Embtoolkit?" Y; then
        cd
        git clone git://git.embtoolkit.org/embtoolkit.git embtoolkit
        cd embtoolkit
        git pull
    fi

    if ask "Config & make Embtoolkit?" Y; then
        #$ make xconfig #qt
        make menuconfig #ncurses
        make

        make rootfs_build
    fi

    if ask "Install Embedian crossdev?" Y; then
        print_status "Installing Embedian, xapt"
        apt-get install emdebian-archive-keyring xapt -y
        echo deb http://www.emdebian.org/debian stable main >> /etc/apt/sources.list
        wget http://http.us.debian.org/debian/pool/main/g/gmp/libgmp3c2_4.3.2+dfsg-1_amd64.deb -O /tmp/libgmp3c2_4.3.2+dfsg-1_amd64.deb
        dpkg -i /tmp/libgmp3c2_4.3.2+dfsg-1_amd64.deb

        print_status "Updating package list.."
        apt-get update -y && apt-get upgrade -y

        if ask "Install g++-4.4-arm-linux-gnueabi ?" Y; then
            apt-get install g++-4.4-arm-linux-gnueabi -y
        fi
    fi

}

install_embedded