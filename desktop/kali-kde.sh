#!/bin/bash
source  ../helper/helper.sh

install_kde(){
    # How to install KDE Plasma Desktop Environment in Kali Linux:
    apt-get install kali-defaults kali-root-login desktop-base kde-plasma-desktop

    # How to install Netbook KDE Plasma Desktop Environment in Kali Linux:
    apt-get install kali-defaults kali-root-login desktop-base kde-plasma-netbook

    # How to install Standard Debian selected packages and frameworks in Kali Linux:
    apt-get install kali-defaults kali-root-login desktop-base kde-standard

    # How to install KDE Full Install in Kali Linux:
    apt-get install kali-defaults kali-root-login desktop-base kde-full

    # How to remove KDE on Kali Linux:
    apt-get remove kde-plasma-desktop kde-plasma-netbook kde-standard
}

if ask "Install KDE?" Y; then
    install_kde
fi