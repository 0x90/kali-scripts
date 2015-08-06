#!/usr/bin/env bash
#
. helper.sh

install_wifi_dependencies(){
    print_status "Installing WiFi tools and dependecies"
    apt_super_upgrade
    sudo apt-get install linux-headers-$(uname -r) build-essential make patch openssl libssl-dev zlib1g zlib1g-dev libssh2-1-dev  \
    gettext libpcap0.8 libpcap0.8-dev python-scapy python-dev cracklib-runtime macchanger-gtk tshark ethtool iw libpcap-dev \
    aircrack-ng sqlite3 libsqlite3-dev libssl-dev -y
}

install_patched_wireless_db(){
    print_status "Installing dependencies for building wireless-db"
    apt-get install -y python-m2crypto libgcrypt11 libgcrypt11-dev libnl-dev git gcc

    print_status "Cloning repos.."
    cd /tmp
    git clone https://github.com/0x90/crda-ct
    git clone https://github.com/0x90/wireless-regdb


    print_status "Building and installing dependencies for building wireless-db"
    cd wireless-regdb/
    make && cp regulatory.bin /lib/crda/regulatory.bin

    print_status "Copying certs.."
    cp root.key.pub.pem ../crda-ct/pubkeys/
    cp /lib/crda/pubkeys/benh@debian.org.key.pub.pem ../crda-ct/pubkeys/

    print_status "Building and installing CRDA"
    cd ../crda-ct
    make && make install

    print_status "Cleanup.."
    cd /tmp
    rm -rf crda-ct
    rm -rf wireless-db
}

# https://forums.kali.org/showthread.php?25715-How-to-install-Wifite-mod-pixiewps-and-reaver-wps-fork-t6x-to-nethunter
install_wifite_fork(){
    cd /tmp
    mkdir backup
    cd backup
    git clone https://github.com/derv82/wifite.git
    git clone https://github.com/aanarchyy/wifite-mod-pixiewps.git
    git clone https://github.com/t6x/reaver-wps-fork-t6x.git
    git clone https://github.com/wiire/pixiewps.git

    cd pixiewps/src/
    make && make install
    cd /tmp/backup/reaver-wps-fork-t6x/src/
    ./configure && make && make install

    cp /tmp/backup/wifite/wifite.py /usr/bin/wifite
    chmod +x /usr/bin/wifite
    cp /tmp/backup/wifite-mod-pixiewps/wifite-ng /usr/bin/wifite-ng
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
    make && make install
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

install_aircrack_svn(){
    if [ -d /opt/aircrack-ng-svn ]; then
        cd /opt/aircrack-ng-svn
        svn up
    else
        svn co http://svn.aircrack-ng.org/trunk/ /opt/aircrack-ng-svn
        cd /opt/aircrack-ng-svn
    fi
    make && make install
    airodump-ng-oui-update
    print_good "Downloaded svn version of aircrack-ng to /opt/aircrack-ng-svn and overwrote package with it."
}

install_radius_wpe(){
    #Checking for free-radius and it not found installing it with the wpe patch.  This code is totally stollen from the easy-creds install file.  :-D
    if [ ! -e /usr/bin/radiusd ] && [ ! -e /usr/sbin/radiusd ] && [ ! -e /usr/local/sbin/radiusd ] && [ ! -e /usr/local/bin/radiusd ]; then
        print_notification "Free-radius is not installed, will attempt to install..."

        mkdir /tmp/freeradius
        print_notification "Downloading freeradius server 2.1.11 and the wpe patch..."
        wget ftp://ftp.freeradius.org/pub/radius/old/freeradius-server-2.1.11.tar.bz2 -O /tmp/freeradius/freeradius-server-2.1.11.tar.bz2
        wget http://www.opensecurityresearch.com/files/freeradius-wpe-2.1.11.patch -O /tmp/freeradius/freeradius-wpe-2.1.11.patch
        cd /tmp/freeradius
        tar -jxvf freeradius-server-2.1.11.tar.bz2
        mv freeradius-wpe-2.1.11.patch /tmp/ec-install/freeradius-server-2.1.11/freeradius-wpe-2.1.11.patch
        cd freeradius-server-2.1.11
        patch -p1 < freeradius-wpe-2.1.11.patch
        print_notification "Installing the patched freeradius server..."

        ./configure && make && make install
        cd /usr/local/etc/raddb/certs/
        ./bootstrap
        rm -r /tmp/freeradius
        print_good "The patched freeradius server has been installed"
    else
        print_good "I found free-radius installed on your system"
    fi
}

install_wifi(){
    install_wifi_dependencies

    if ask "Install patched wireless-db?" Y; then
        install_patched_wireless_db
    fi

    if ask "Install wifite-fork + pixie-wps?" Y; then
        install_wifite_fork
    fi

    if ask "Install Lorcon library with python and ruby bindings?" Y; then
        install_lorcon
    fi

    if ask "Install horst (Wireless L2 sniffer)?" Y; then
        install_horst
    fi

    if ask "Install pyrit from source?" N; then
        install_pyrit
    fi

    if ask "Install aircrack-ng from SVN?" N; then
        install_aircrack_svn
    fi

    if ask "Install freeradius server 2.1.11 with WPE patch?" N; then
        install_radius_wpe
    fi
}

install_bluetooth(){
    print_status "Installing dependencies for bluetooth hacking"
    apt-get install cmake libusb-1.0-0-dev make gcc g++ pkg-config libpcap-dev \
    python-numpy python-pyside python-qt4 build-essential libpcap-dev

    print_status "Installing BlueMaho, redfang, spooftooph, obexfs, bluewho, btscanner and others"
    # wget "https://wiki.thc.org/BlueMaho?action=AttachFile&do=get&target=bluemaho_v090417.tgz"
    apt-get install -y anyremote redfang spooftooph python-bluez obexfs bluepot bluewho btscanner \
    bluez-utils bluelog libbluetooth-dev spectools bluemaho
    apt-get install -y libopenobex1:i386 libopenobex1-dev:i386 libbluetooth-dev:i386

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
        cmake .. && make && make install

        print_status "Installing ubertooth"
        wget https://github.com/greatscottgadgets/ubertooth/archive/2014-02-R2.tar.gz -O ubertooth-2014-02-R2.tar.gz
        tar xf ubertooth-2014-02-R2.tar.gz
        cd ubertooth-2014-02-R2/host
        mkdir build
        cd build
        cmake .. && make && make install

        if ask "Install bluetooth hacking tools?" Y; then
            print_status "Installing dependencies for bluetooth hacking"
            sudo apt-get install libpcap0.8-dev libcap-dev pkg-config build-essential libnl-dev libncurses-dev libpcre3-dev libpcap-dev libcap-dev

            wget https://kismetwireless.net/code/kismet-2013-03-R1b.tar.xz
            tar xf kismet-2013-03-R1b.tar.xz
            cd kismet-2013-03-R1b
            ln -s ../ubertooth-2014-02-R2/host/kismet/plugin-ubertooth .
            ./configure && make && make plugins && make suidinstall && make plugins-install
            # echo Add "pcapbtbb" to the "logtypes=..." line in kismet.conf
        fi

        if ask "Install bluetooth hacking tools?" Y; then
            print_status "Installing dependencies for bluetooth hacking"
            apt-get install wireshark wireshark-dev libwireshark3 libwireshark-dev

            cd libbtbb-2014-02-R2/wireshark/plugins/btbb
            mkdir build
            cd build
            cmake -DCMAKE_INSTALL_LIBDIR=/usr/lib/x86_64-linux-gnu/wireshark/libwireshark3/plugins ..
            make && make install
        fi
    fi
}

install_sdr(){
    apt-get install -y kali-linux-sdr
}

install_wireless(){
    if ask "Install WiFi hacking tools?" Y; then
        install_wifi
    fi

    if ask "Install Bluetooth hacking tools + Kismet + BTBB from source?" N; then
        install_bluetooth
    fi

    if ask "Install SDR tools?" Y; then
        install_sdr
    fi
}

if [ "${0##*/}" = "wireless.sh" ]; then
    install_wireless
fi

