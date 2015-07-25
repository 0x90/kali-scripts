#!/bin/bash
#

source  ../helper/helper.sh

echo "Installing Lorcon dependecies"
apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y


echo "Installing Lorcon dependecies"
sudo apt-get install libpcap-dev aircrack-ng sqlite3 libsqlite3-dev libssl-dev -y

sudo apt-get install linux-headers-$(uname -r) build-essential make patch openssl libssl-dev zlib1g zlib1g-dev libssh2-1-dev  \
 gettext libpcap0.8 libpcap0.8-dev python-scapy python-dev cracklib-runtime macchanger-gtk tshark ethtool iw


# https://forums.kali.org/showthread.php?25715-How-to-install-Wifite-mod-pixiewps-and-reaver-wps-fork-t6x-to-nethunter
install_wifite_fork(){
    cd /root
    mkdir backup
    cd backup
    git clone https://github.com/derv82/wifite.git
    git clone https://github.com/aanarchyy/wifite-mod-pixiewps.git
    git clone https://github.com/t6x/reaver-wps-fork-t6x.git
    git clone https://github.com/wiire/pixiewps.git

    cd pixiewps/src/
    make && make install
    cd /root/backup/reaver-wps-fork-t6x/src/
    ./configure && make && make install

    cp /root/backup/wifite/wifite.py /usr/bin/wifite
    chmod +x /usr/bin/wifite
    cp /root/backup/wifite-mod-pixiewps/wifite-ng /usr/bin/wifite-ng
    chmod +x /usr/bin/wifite-ng
}

install_lorcon(){
    echo "Installing Lorcon"
    cd /tmp
    git clone https://github.com/0x90/lorcon
    cd lorcon
    ./configure && make && make install

    # install pylorcon
    echo "Install pylorcon2"
    cd pylorcon2
    python setup.py build && python setup.py install

    # to make lorcon available to metasploit
    echo "Install ruby lorcon"
    cd ../ruby-lorcon/
    ruby extconf.rb
    make
    make install
}

install_pyrit(){
    apt-get install nvidia-cuda-toolkit nvidia-opencl-icd

    echo "Step 3.a: Install Pyrit prerequisites"
    apt-get install python2.7-dev python2.7-libpcap libpcap-dev
    echo "Step 3.b: Remove existing installation of Pyrit"
    apt-get remove pyrit

    echo "Step 2: Download Pyrit and Cpyrit"
    cd /usr/src
    wget https://pyrit.googlecode.com/files/pyrit-0.4.0.tar.gz
    wget https://pyrit.googlecode.com/files/cpyrit-cuda-0.4.0.tar.gz
}

install_horst(){
    # http://br1.einfach.org/tech/horst/
    apt-get install libncurses5-dev libnl-genl-3-dev -y
    cd /tmp
    git clone git://br1.einfach.org/horst
    cd horst
    make && cp horst /usr/bin
    rm -rf /tmp/horst
}

# GNU Radio 802.11
# An IEEE 802.11 a/g/p Transceiver  http://www.ccs-labs.org/projects/wime/
# git clone https://github.com/bastibl/gr-ieee802-11
