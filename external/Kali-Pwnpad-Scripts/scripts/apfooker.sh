#!/bin/bash
#####################
# Pwnpad port of the AP_Fuck** script found on top-hat forums
# Original Author MatTouFoutu
# pwnpad conversion by: SecureMaryland
# Script for various means to deauth users on wireless APs
#####################
#####################
VERSION="1.0"
###################################################################################################################
f_intro(){
clear
echo ""
echo -e "\e[00;32m#############################################################\e[00m"
echo ""
echo "*** AP_fuck**.py Scanner script for the Pwnpad Version $VERSION  ***"
echo "*** Author: @securemaryland ***"
echo "*** Launches AP_fuck**.py tool from Top-Hat-Security Forums  ***"
echo "*** Python portion written by matToufoutu ***"
echo ""
echo -e "\e[00;32m#############################################################\e[00m"
echo ""
echo ""
echo -e "\e[1;33mPress Enter to continue\e[00m"
echo ""
read ENTERKEY
clear
}
##########################################################################################################################
##########################################################################################################################
# Function to check for wlan1 and set up monitoring
f_wireless(){
adaptor=`ip addr |grep wlan1`
if [ -z "$adaptor" ]; then
echo "This script requires wlan1 to be plugged in."
echo "I cant see it so exiting now. Try again when wlan1 is plugged in."
exit 1
fi
echo " Found wlan1 now checking if monitor mode is on - don't worry I will turn it on if it isn't running"
iwconfig |grep Monitor>/dev/null
if [ $? = 1 ]
then
	echo
	echo "Monitor mode doesn't seem to be running. I will issue an airmon-ng start wlan1 to start it"
	echo ""
	airmon-ng start wlan1
else
	echo "Monitor mode appears to be running. Moving on."
fi
echo ""
echo -e "\e[1;33m-----------------------------------------------------------------\e[00m"
echo "AP_fuck**.py expects you to know the ESSID and BSSID for the APs you want to F with. If you don't know those may I suggest running airodump-ng in another window"
echo ""
echo "Press enter to launch AP_fuc**.py"
echo -e "\e[1;33m-----------------------------------------------------------------\e[00m"
read ENTERKEY
}
##########################################################################################################################
f_intro
f_wireless
python /opt/pwnpad/scripts/AP_fucker.py

