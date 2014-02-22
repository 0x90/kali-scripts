#!/bin/bash
#
# Script to perform some common system operations
#
cd /opt/pwnpad/captures/wifite
while :
do
clear
echo "************************"
echo "* WIFITE QUICK SELECT *"
echo "************************"
echo "[1] Regular Wifite"
echo "[2] Attack all WEP"
echo "[3] Capture all WPA (no cracking)"
echo "[4] Attack WPS with power over 40+"
echo "[0] Exit"
echo -n "Enter your menu choice [1-3]: "
read yourch
case $yourch in
1) wifite mac ;;
2) wifite -all -wep mac ;;
3) wifite -all -wpa --dict none mac ;;
4) wifite -p 40 -wps ;;
0) exit 0 ;;
*) echo "Incorrect choice..." ;
echo "Press Enter to continue. . ." ; read ;; esac
done
