#!/bin/bash
#####################################
clear
echo "Installing necessary files..."
apt-get update
apt-get install libssl-dev libnl-dev haveged 
sleep 2
echo "Installing FreeRADIUS Wireless Pwnage Edition (WPE)..."
sleep 3
cd /opt/pwnpad/
git clone https://github.com/brad-anton/freeradius-wpe.git
cd freeradius-wpe
wget http://ftp.cc.uoc.gr/mirrors/ftp.freeradius.org/freeradius-server-2.1.12.tar.bz2
sleep 3
tar jxvf freeradius-server-2.1.12.tar.bz2
rm freeradius-server-2.1.12.tar.bz2
cd freeradius-server-2.1.12
patch -p1 < ../freeradius-wpe.patch
./configure
make
cd /usr/local/etc/raddb/certs
./bootstrap && ldconfig
echo "Completed FreeRADIUS Wireless Pwnage Edition Install"
sleep 5
#####################################
echo "Installing hostapd-wpe (Wireless Pwnage Edition)"
sleep 2
cd /root
git clone https://github.com/OpenSecurityResearch/hostapd-wpe
cd hostapd-wpe
wget http://hostap.epitest.fi/releases/hostapd-1.1.tar.gz
tar -zxf hostapd-1.1.tar.gz
cd hostapd-1.1
patch -p1 < /root/hostapd-wpe/hostapd-wpe.patch 
cd hostapd
make
make install
cd /root/hostapd-wpe/certs
./bootstrap
echo "hostapd-wpe (Wireless Pwnage Edition) install completed"
echo "cleaning up..."
rm -rf /root/hostapd/hostapd-1.1
rm -rf /root/hostapd/hostapd-1.1.tar.gz
rm -rf /opt/pwnpad/freeradius-wpe
#####################################
echo "Downloading create_ap to /usr/bin"
cd /usr/bin
wget https://raw.github.com/oblique/create_ap/master/create_ap
chmod +x create_ap
#####################################
echo "Download RadiusWPE2John/Rad-free"
cd /opt/pwnpad/
mkdir freeradius
cd freeradius
wget 'http://pastebin.com/raw.php?i=RJwgbwNh'
mv 'raw.php\?i\=RJwgbwNh' RadiusWPE2John.py
chmod +x RadiusWPE2John.py
wget 'https://raw.github.com/binkybear/Kali-Pwnpad-Scripts/master/rad-free.sh'
chmod +x rad-free.sh
echo "Try rad-free.sh in /opt/pwnpad/freeradius folder"
# NOTES ########################
# Start FreeRADIUS #############
#
# radiusd  
# tail -f /usr/local/var/log/radius/freeradius-server-wpe.log
# 
# Start Hostapd ################
#
# hostapd -d ~/hostapd-wpe/hostapd-local-eapfast.conf"