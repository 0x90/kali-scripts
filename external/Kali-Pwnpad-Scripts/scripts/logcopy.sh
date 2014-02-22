#!/bin/bash
# Log copy utility for pwnpad use by:
# www.securemaryland.org
# @securemaryland
#Tested on Pwnpad Community Edition
# Copies files to /sdcard so you can easially move them to USB/other computer
VERSION="1.0"
###################################################################################################################
# Intro
#
f_intro(){
clear
echo ""
echo ""
echo -e "\e[00;32m#############################################################\e[00m"
echo ""
echo "*** Log Copy for the Pwnpad Version $VERSION  ***"
echo "*** Author: @securemaryland ***"
echo "*** Tars files up and moves them to /sdcard so they can be copied to USB  ***"
echo ""
echo -e "\e[00;32m#############################################################\e[00m"
echo ""
echo ""
echo -e "\e[1;33mPress Enter to continue\e[00m"
echo ""
read ENTERKEY
clear
TODAY=`date +%Y%m%d`
}

#####################################################################################################################
###################################################################################################################
# Main body of program does the runing of tasks
#
f_runscan(){
logdir="/sdcard/pwnpadlogs/"$TODAY""
mkdir -p "$logdir"
while true; do
echo "What files would you like to save today"
echo "1) The /opt/pwnpad/captures directory."
echo "2) Easy-Creds logs."
echo "3) Kismet logs."
echo "4) Wifite logs."
echo "5) All the above."
read -p "Which one [1-5]?: " choice
case $choice in
1)		Option="captures"
		cd /opt/pwnpad
		echo -e "\e[1;31m--------------------------------------------------\e[00m"
		echo "Copying the Captures directory..."
		tar -cvzf captures.tgz captures/ >/dev/null 2>&1
		echo ""
		echo "Done with Captures directory."
		mv captures.tgz "$logdir"
		echo -e "\e[1;31m--------------------------------------------------\e[00m"
			break;
			;;
2)		Option="Easy-Creds"
		echo -e "\e[1;31m--------------------------------------------------\e[00m"
		echo "Copying the Easycreds logs..."
		cd easy-creds
		tar -cvzf easycreds.tgz easy-cred* *.txt >/dev/null 2>&1
		echo ""
		echo "Done with Easycreds logs."
		mv easycreds.tgz "$logdir"
		echo -e "\e[1;31m--------------------------------------------------\e[00m"
			break;
			;;
3)		Option="Kismet"
		echo -e "\e[1;31m--------------------------------------------------\e[00m"
		echo "Copying the Kismet data logs..."
		cd /opt/pwnpad/captures/kismet
		tar -cvzf kismet.tgz kismet-* >/dev/null 2>&1
		echo ""
		echo "Done with Kismet logs."
		mv kismet.tgz "$logdir"
		echo -e "\e[1;31m--------------------------------------------------\e[00m"
		break;
		;;
4)		Option="Wifite"		
		echo -e "\e[1;31m--------------------------------------------------\e[00m"
		echo "Copying the Wifite data logs..."
		cd /opt/pwnpad/captures/wifite
		tar -cvzf Wifite.tgz cracked.txt hs/>/dev/null 2>&1
		echo ""
		echo "Done with Wifite logs."
		mv Wifite.tgz "$logdir"
		echo -e "\e[1;31m--------------------------------------------------\e[00m"
		break;
		;;
5)		Option="All"		 		
		cd /opt/pwnpad
		echo -e "\e[1;31m--------------------------------------------------\e[00m"
		echo "Copying the Captures directory..."
		tar -cvzf captures.tgz captures/ >/dev/null 2>&1
		echo ""
		echo "Done with Captures directory."
		mv captures.tgz "$logdir"
		echo -e "\e[1;31m--------------------------------------------------\e[00m"
		echo "Copying the Easycreds data logs..."
		cd /opt/pwnpad/easy-creds
		tar -cvzf easycreds.tgz easy-cred* *.txt >/dev/null 2>&1
		echo ""
		echo "Done with Easycreds logs."
		mv easycreds.tgz "$logdir"
		echo -e "\e[1;31m--------------------------------------------------\e[00m"
		echo "Copying the Kismet data logs..."
		cd /opt/pwnpad/captures/kismet
		tar -cvzf kismet.tgz kismet-* >/dev/null 2>&1
		echo ""
		echo "Done with Kismet logs."
		mv kismet.tgz "$logdir"
		echo -e "\e[1;31m--------------------------------------------------\e[00m"
		echo "Copying the Wifite data logs..."
		cd /opt/pwnpad/captures/wifite
		tar -cvzf Wifite.tgz cracked.txt hs/>/dev/null 2>&1
		echo ""
		echo "Done with Wifite logs."
		mv Wifite.tgz "$logdir"
		break;
		;;
*) echo "Invalid Input. Please try again."
;;
esac
done
echo ""
echo -e "\e[1;33m The log files have been copied.\e[00m"
}
#####################################################################################################################
######################################################################################################################
# Out put
# Builds some outputfiles
f_output() {
echo "The following options were selected  "$Option""  > "$logdir"/options.txt
echo ""
echo -e "\e[1;33m-----------------------------------------------------------------------\e[00m"
echo "The following can be found in "$logdir""
echo -e "\e[1;33m-----------------------------------------------------------------------\e[00m"
lsFiles=$(ls "$logdir")
echo -e "\e[00;32m$lsFiles\e[00m"
echo ""
}
#####################################################################################################################
#####################################################################################################################
f_intro
f_runscan
f_output
