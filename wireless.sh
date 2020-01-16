#!/usr/bin/env bash
#
. helper.sh

install_wifi_basic(){
    print_status "Installing WiFi dependecies..."
    sudo apt-get install -y build-essential make patch openssl pkg-config libssl-dev zlib1g zlib1g-dev libssh2-1-dev  \
    gettext libpcap0.8 libpcap0.8-dev python-scapy python-dev cracklib-runtime libpcap-dev sqlite3 libsqlite3-dev libssl-dev

    print_status "Installing WiFi tools and dependecies"
    sudo apt-get install -y kali-linux-wireless aircrack-ng kismet kismet-plugins giskismet horst wavemon urfkill \
    hostapd dnsmasq iw tshark horst linssid cupid-wpasupplicant cupid-hostapd
    apt-get install libncurses5-dev libnl-genl-3-dev -y

    echo "Install CUDA support"
    apt-get install nvidia-cuda-toolkit nvidia-opencl-icd
}

install_patched_wireless_db(){
    print_status "Installing dependencies for building wireless-db"
    apt-get install -y python-m2crypto libgcrypt20 libgcrypt20-dev git gcc libnl-genl-3-dev

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
    # REG_BIN path fix for Kali Linux
    export REG_BIN=/lib/crda/regulatory.bin
    make && make install

    print_status "Cleanup.."
    cd /tmp
    rm -rf crda-ct wireless-db
}

# https://forums.kali.org/showthread.php?25715-How-to-install-Wifite-mod-pixiewps-and-reaver-wps-fork-t6x-to-nethunter
install_wifite_fork(){
    apt-get install libsqlite3-dev libpcap-dev -y
    cd /tmp

    git clone https://github.com/derv82/wifite.git
    git clone https://github.com/aanarchyy/wifite-mod-pixiewps.git
    git clone https://github.com/t6x/reaver-wps-fork-t6x.git
    git clone https://github.com/wiire/pixiewps.git

    cd pixiewps/src/
    make && make install
    cd /tmp/reaver-wps-fork-t6x/src/
    ./configure && make && make install

    cp /tmp/wifite/wifite.py /usr/bin/wifite-old
    chmod +x /usr/bin/wifite-old
    cp /tmp/wifite-mod-pixiewps/wifite-ng /usr/bin/wifite-ng
    chmod +x /usr/bin/wifite-ng

    cd /tmp
    rm -rf wifite
    rm -rf wifite-mod-pixiewps
    rm -rf reaver-wps-fork-t6x
    rm -rf pixiewps
}

install_lorcon(){
    echo "Installing Lorcon"
    cd /tmp
    git clone https://github.com/0x90/lorcon
    cd lorcon
    ./configure --prefix=/usr && make && make install

    # install pylorcon
    echo "Install pylorcon2"
    cd pylorcon2
    python setup.py build && python setup.py install
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

install_penetrator(){
    apt-get install libpcap-dev libssl-dev -y
    cd /tmp
    git clone https://github.com/xXx-stalin-666-money-xXx/penetrator-wps.git
    cd penetrator-wps/
    ./install.sh
    cp penetrator /usr/bin
}

install_hotspotd(){
  echo "Install hotspotd dependencies"
  apt install hostapd dnsmasq -y

  echo "Installing hotspotd"
  cd /tmp
  git clone https://github.com/0x90/hotspotd
  cd hotspotd
  sudo python2 setup.py install

  rm -rf /tmp/hotspotd
}

install_mana(){
  echo "Install MANA dependencies"
  apt-get --yes install build-essential pkg-config git libnl-genl-3-dev libssl-dev

  echo "clone hostapd MANA"
  cd /tmp
  git clone https://github.com/sensepost/hostapd-mana
  cd hostapd-mana
  make -C hostapd
  make -C hostapd install
  ln -s /usr/local/bin/hostapd /usr/bin/hostapd-mana

  echo "Install berate_ap"
  git clone https://github.com/sensepost/berate_ap
  cd berate_ap
  make && make install

  echo "Cleaning up"
  rm -rf /tmp/hostapd-mana /tmp/berate_ap
  # TODO: https://github.com/sensepost/wpa_sycophant
}

install_hccapx(){
  echo "Installing hcxtools dependencies"
  apt-get install -y libssl-dev libz-dev libpcap-dev libcurl4-openssl-dev

  echo "Installing hcxtools"
  cd /tmp
  git clone https://github.com/ZerBea/hcxtools
  cd hcxtools
  make && make install

  echo "Installing hcxdumptool"
  cd /tmp
  git clone https://github.com/ZerBea/hcxdumptool
  cd hcxdumptool
  make && make install


  # go get github.com/vlad-s/hcpxread

  echo "Cleanup"
  rm -rf /tmp/hcxdumptool /tmp/hcxdumptool

  # https://github.com/hashcat/hashcat
  # https://github.com/hashcat/hashcat-utils
}

# TODO: https://github.com/ghostop14/sparrow-wifi/

install_wifi(){
    if ask "Install basic wireless hacking tools?" Y; then
        install_wifi_basic
    fi

    if ask "Install patched wireless-db?" Y; then
        install_patched_wireless_db
    fi

    if ask "Install tools to manage *.hccapx files" Y; then
        install_hccapx
    fi

    if ask "Install Lorcon library with python bindings?" Y; then
        install_lorcon
    fi

    if ask "Install hotspotd?" Y; then
        install_hotspotd
    fi

    if ask "Install berate_ap & MANA" Y; then
       install_mana
    fi

    if ask "Install WPS penetrator?" N; then
        install_penetrator
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
      print_status "Installing dependencies for bluetooth hacking"
      sudo apt-get install libpcap0.8-dev libcap-dev pkg-config build-essential libnl-dev libncurses-dev libpcre3-dev libpcap-dev \
      libcap-dev obexfs redfang spooftooph sakis3g ubertooth gpsd btscanner bluelog  bluesnarfer bluez-tools bluewho

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

if [ "${0##*/}" = "wireless.sh" ]; then
    if ask "Install WiFi hacking tools?" Y; then
        install_wifi
    fi

    if ask "Install Bluetooth hacking tools + Kismet + BTBB from source?" N; then
        install_bluetooth
    fi

    if ask "Install SDR tools?" Y; then
        install_sdr
    fi
fi
