#!/usr/bin/env bash
#
. helper.sh

install_arduino(){
    apt-get install -y arduino
}

install_uart_tools(){
    apt-get install -y ftdi-eeprom libftdi1 python-ftdi minicom python-serial cutecom libftdi-dev python-ftdi -y
}

install_onchip(){
    apt-get install -y skyeye openocd
}

install_rom_tools(){
    apt-get install -y flashrom
}

install_signal_analysis()
{
    # TODO: OLS install
    apt-get install -y libsigrok0-dev sigrok libsigrokdecode0-dev git-core gcc g++ make autoconf autoconf-archive \
    automake libtool pkg-config libglib2.0-dev libglibmm-2.4-dev libzip-dev libusb-1.0-0-dev libftdi-dev check \
    doxygen python-numpy python-dev python-gi-dev python-setuptools swig default-jdk

    cd /tmp && mkdir sigrok
    cd sigrok

    #libserial
    git clone git://sigrok.org/libserialport
    cd libserialport
    ./autogen.sh &&./configure && make && make install
    cd ..

    #SIGROK
    git clone git://sigrok.org/libsigrok
    cd libsigrok
    ./autogen.sh &&./configure && make && make install
    cd ..

    # SIGROK GUI dependencies
    sudo apt-get install cmake libqt4-dev libboost-dev libboost-test-dev libboost-thread-dev libboost-system-dev
    apt-get install git-core g++ make cmake libtool pkg-config \
    libglib2.0-dev libqt4-dev libboost-test-dev libboost-thread-dev\
    libboost-filesystem-dev libboost-system-dev

    # SIGROK GUI
    git clone git://sigrok.org/pulseview
    cd pulseview
    ./autogen.sh &&./configure && make && make install
    cd ../..

    rm -rf /tmp/sigrok
}

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
        git submodule init && git submodule update

        # Configure OpenOCD (make sure to enable the driver for your adapter)
        autoreconf -i && ./configure

        # Build and install
        make -j && make install
    fi
}

install_fpga(){
    print_status "Installling tools for FPGA..."
}

install_hardware(){
    if ask "Install tools for Arduino?" Y; then
        install_arduino
    fi

    if ask "Install tools for UART, FTDI libs?" Y; then
        install_uart_tools
    fi

    if ask "Install tool for onchip debugging and emulation" Y; then
        if ask "Do you want to install Avatar?" N; then
            install_avatar
        else
            install_onchip
        fi
    fi

    if ask "Install tools for signal analysis (OLS,)?" Y; then
        install_signal_analysis
    fi

    if ask "Install tools for FPGA?" Y; then
        install_fpga
    fi
}

if [ "${0##*/}" = "hardware.sh" ]; then
    install_hardware
fi
