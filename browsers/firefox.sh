#!/usr/bin/env bash
#
source ../helper/helper.sh

install_firefox(){
    apt-get remove iceweasel
#    echo >> /etc/apt/sources.list
#    echo "deb http://downloads.sourceforge.net/project/ubuntuzilla/mozilla/apt all main" >> /etc/apt/sources.list
    echo "deb http://downloads.sourceforge.net/project/ubuntuzilla/mozilla/apt all main" > /etc/apt/sources.list.d/ubuntuzilla.list
    apt-key adv --recv-keys --keyserver keyserver.ubuntu.com C1289A29
    apt-get update -y &&  apt-get install firefox-mozilla-build -y
}