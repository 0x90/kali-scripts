#!/bin/bash
. helper.sh

install_mitm(){
    print_notification "Installing ettercap, haxorblox and ghost-phisher"
    apt-get install -y  ettercap hamster-sidejack ferret-sidejack dsniff gawk snarf ngrep ghost-phisher

    if ask "Do you want to install Intercepter-NG?" Y; then
        print_notification "Adding i386 support"
        dpkg --add-architecture i386 &&
        apt-get update -y && apt-get upgrade -y
        apt-get install ia32-libs -y

        print_notification "Installing dependencies"
        apt-get install unzip wget lib32ncurses5-dev -y

        print_notification "Download & unpack"
        cd /tmp
        wget http://intercepter.nerf.ru/Intercepter-NG.CE.05.zip
        unzip Intercepter-NG.CE.05.zip
        mv intercepter_linux /usr/bin/intercpeter-ng
        chmod +x /usr/bin/intercpeter-ng
    fi

    if ask "Install yamas.sh?" Y; then
        apt-get install -y arpspoof ettercap-text-only sslstrip
        wget http://comax.fr/yamas/bt5/yamas.sh -O /usr/bin/yamas
        chmod +x /usr/bin/yamas
    fi

    if ask "Install parponera?" N; then
        #TODO: testing...
        git clone https://code.google.com/p/paraponera/ ~/parponera
        cd ~/parponera
        ./install.sh
    fi
}

if ask "Do you want install MITM tools?" Y; then
    install_mitm
fi