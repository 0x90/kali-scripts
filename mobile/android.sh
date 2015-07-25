#!/usr/bin/env bash

android_tools(){
    if ask "Install tools for Andoid hacking?" Y; then
        apt-get install -y abootimg smali android-sdk apktool dex2jar

        #TODO: check if file exists
        add-apt-repository ppa:nilarimogard/webupd8
        apt-get update -y && apt-get install android-tools-adb android-tools-fastboot
    fi
}