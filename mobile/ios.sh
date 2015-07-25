#!/usr/bin/env bash
#
source ../helper/helper.sh

# Install tools for iphone
install_idevice(){
    if ask "Do you want to install tools for work with iDevice?" Y; then
        print_status "Installing tools.."
        apt-get install -y libimobiledevice1 python-imobiledevice usbmuxd iphone-backup-analyzer ipheth-utils ifuse
    fi
}

ios_tools(){
    if ask "Install tools for iOS hacking?" Y; then
        apt-get install -y ifuse ipheth-utils iphone-backup-analyzer libimobiledevice-utils libimobiledevice2 python-imobiledevice usbmuxd
    fi
}

msf_on_iphone(){
    apt-get update && apt-get dist-upgrade && apt-get install wget subversion

    wget http://ininjas.com/repo/debs/ruby_1.9.2-p180-1-1_iphoneos-arm.deb
    wget http://ininjas.com/repo/debs/iconv_1.14-1_iphoneos-arm.deb
    wget http://ininjas.com/repo/debs/zlib_1.2.3-1_iphoneos-arm.deb

    dpkg -i iconv_1.14-1_iphoneos-arm.deb
    dpkg -i zlib_1.2.3-1_iphoneos-arm.deb
    dpkg -i ruby_1.9.2-p180-1-1_iphoneos-arm.deb

    cd /private/var
    svn co https://www.metasploit.com/svn/framework3/trunk/ msf3

    ruby msfconsole
}
install_idevice