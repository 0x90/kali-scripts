#!/usr/bin/env bash
#
. helper.sh

mobile_tools()
{
    apt-get install gammu
}


# Install tools for iphone
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

android_tools(){
    if ask "Install tools for Andoid hacking?" Y; then
        apt-get install -y abootimg smali android-sdk apktool dex2jar
        apt_add_repo ppa:nilarimogard/webupd8
        apt-get install -y android-tools-adb android-tools-fastboot
    fi
}