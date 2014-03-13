#!/bin/bash
. helper.sh

android(){
    if ask "Install tools for Andoid hacking?" Y; then
        apt-get install -y abootimg smali android-sdk apktool dex2jar

        #TODO: check if file exists
        add-apt-repository ppa:nilarimogard/webupd8
        apt-get update -y && apt-get install android-tools-adb android-tools-fastboot
    fi
}

ios(){
    if ask "Install tools for iOS hacking?" Y; then
        apt-get install -y ifuse ipheth-utils iphone-backup-analyzer libimobiledevice-utils libimobiledevice2 python-imobiledevice usbmuxd
    fi
}

#TODO: add Windows Phone tools?

check_euid
android
ios