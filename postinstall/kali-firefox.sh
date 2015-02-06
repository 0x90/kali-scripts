#!/bin/sh

apt-get remove iceweasel
echo >> /etc/apt/sources.list
echo "deb http://downloads.sourceforge.net/project/ubuntuzilla/mozilla/apt all main" >> /etc/apt/sources.list 
apt-key adv --recv-keys --keyserver keyserver.ubuntu.com C1289A29
apt-get update
apt-get install firefox-mozilla-build