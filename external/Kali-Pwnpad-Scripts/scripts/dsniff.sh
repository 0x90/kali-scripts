#!/bin/bash
# Dsniff Script adapted from PWNPAD script

##################################################
f_interface(){
        clear

echo "Select which interface you would like to sniff on? (1-6):"
echo 
echo "1. eth0  (USB ethernet adapter)"
echo "2. wlan0  (Internal Nexus Wifi)"
echo "3. wlan1  (USB TPlink Atheros)"
echo "4. mon0  (monitor mode interface)"
echo "5. at0  (Use with EvilAP)"
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


clear

echo 
echo "Would you like to log data?"
echo
echo "Captures saved to /opt/pwnpad/captures/sniffed"
echo
echo "1. Yes"
echo "2. No "
echo

read -p "Choice: " logchoice

#echo 1 > /proc/sys/net/ipv4/ip_forward

if [ $logchoice -eq 1 ] 
then

        filename=/opt/pwnpad/captures/sniffed$(date +%F-%H%M).log

        dsniff -i $interface -w $filename

else

dsniff -i $interface

fi
