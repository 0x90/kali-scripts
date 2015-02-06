#!/bin/bash
#
# https://github.com/greatscottgadgets/ubertooth/wiki/Build-Guide
# http://www.splitbits.com/2014/05/14/ubertooth-spectools-chromebook/
# http://penturalabs.wordpress.com/2013/09/01/ubertooth-open-source-bluetooth-sniffing/
#

source  ../helper/helper.sh

install_bluetooth(){
    print_status "Installing dependencies for bluetooth hacking"
    apt-get install cmake libusb-1.0-0-dev make gcc g++ pkg-config libpcap-dev \
    python-numpy python-pyside python-qt4 build-essential libpcap-dev python-pyside python-numpy

    print_status "Installing BlueMaho, redfang, spooftooph, obexfs, bluewho, btscanner and others"
    # wget "https://wiki.thc.org/BlueMaho?action=AttachFile&do=get&target=bluemaho_v090417.tgz"
    apt-get install anyremote redfang spooftooph python-bluez obexfs bluepot bluewho btscanner \
    bluez-utils bluelog libopenobex1:i386 libopenobex1-dev:i386 libbluetooth-dev:i386 libbluetooth-dev spectools bluemaho


    if ask "Install ubertooth hacking tools?" Y; then

        print_status "Installing  pyusb-1.0.0b1"
        pip install https://github.com/walac/pyusb/archive/1.0.0b1.tar.gz
        # PyUSB 1.0 is not yet available from the Debian, Ubuntu or Homebrew repositories,
        #if you don't already have it installed you will need to fetch and build it as follows:
#        cd /tmp
#        wget https://github.com/walac/pyusb/archive/1.0.0b1.tar.gz -O pyusb-1.0.0b1.tar.gz
#        tar xvf pyusb-1.0.0b1.tar.gz
#        cd pyusb-1.0.0b1
#        sudo python setup.py install
#
#        cd /tmp
#        rm pyusb-1.0.0b1.tar.gz
#        rm -rf pyusb-1.0.0b1


        print_status "Installing libbtbb from sources"
        wget https://github.com/greatscottgadgets/libbtbb/archive/2014-02-R2.tar.gz -O libbtbb-2014-02-R2.tar.gz
        tar xf libbtbb-2014-02-R2.tar.gz
        cd libbtbb-2014-02-R2
        mkdir build
        cd build
        cmake ..
        make
        make install

        print_status "Installing ubertooth"
        wget https://github.com/greatscottgadgets/ubertooth/archive/2014-02-R2.tar.gz -O ubertooth-2014-02-R2.tar.gz
        tar xf ubertooth-2014-02-R2.tar.gz
        cd ubertooth-2014-02-R2/host
        mkdir build
        cd build
        cmake ..
        make
        make install


        if ask "Install bluetooth hacking tools?" Y; then
            print_status "Installing dependencies for bluetooth hacking"
            sudo apt-get install libpcap0.8-dev libcap-dev pkg-config build-essential libnl-dev libncurses-dev libpcre3-dev libpcap-dev libcap-dev


            wget https://kismetwireless.net/code/kismet-2013-03-R1b.tar.xz
            tar xf kismet-2013-03-R1b.tar.xz
            cd kismet-2013-03-R1b
            ln -s ../ubertooth-2014-02-R2/host/kismet/plugin-ubertooth .
            ./configure
            make && make plugins
            sudo make suidinstall
            sudo make plugins-install
            # echo Add "pcapbtbb" to the "logtypes=..." line in kismet.conf
        fi


        if ask "Install bluetooth hacking tools?" Y; then
            print_status "Installing dependencies for bluetooth hacking"
            apt-get install wireshark wireshark-dev libwireshark3 libwireshark-dev


            cd libbtbb-2014-02-R2/wireshark/plugins/btbb
            mkdir build
            cd build
            cmake -DCMAKE_INSTALL_LIBDIR=/usr/lib/x86_64-linux-gnu/wireshark/libwireshark3/plugins ..
            make
            sudo make install
        fi

    fi
}

if ask "Install bluetooth hacking tools?" Y; then
    install_bluetooth
fi