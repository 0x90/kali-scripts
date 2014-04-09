#!/bin/sh

apt-get update
apt-get dist-upgrade
apt-get install wget subversion



wget http://ininjas.com/repo/debs/ruby_1.9.2-p180-1-1_iphoneos-arm.deb
wget http://ininjas.com/repo/debs/iconv_1.14-1_iphoneos-arm.deb
wget http://ininjas.com/repo/debs/zlib_1.2.3-1_iphoneos-arm.deb

dpkg -i iconv_1.14-1_iphoneos-arm.deb
dpkg -i zlib_1.2.3-1_iphoneos-arm.deb
dpkg -i ruby_1.9.2-p180-1-1_iphoneos-arm.deb

cd /private/var
svn co https://www.metasploit.com/svn/framework3/trunk/ msf3

ruby msfconsole
