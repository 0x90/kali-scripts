#!/bin/bash
# Find My Hash for pwnpad  by:
# www.securemaryland.org
# @securemaryland
#Tested on Pwnpad Community Edition
# Uses the ruby tool findmyhash
VERSION="1.0"
###################################################################################################################
f_intro(){
clear
echo ""
echo ""
echo -e "\e[00;32m#############################################################\e[00m"
echo ""
echo "*** Find my hash script for the Pwnpad Version $VERSION  ***"
echo "*** Author: @securemaryland ***"
echo "*** Launches the findmyhash tool from https://code.google.com/p/findmyhash/  ***"
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
#####################################################################################################################
# User Config Options
# Turn on/off the option
# Sets the scan options: Hash type and Single/File
f_options(){
#moving to the install directory to make sure everything runs ok even if findmyhash isn't in the path
cd "$installdir"
# finding out what kind of scan to run
while true; do
echo "What Hash are you trying to break option would you like to use?"
echo ""
echo "1) MD4 - RFC 1320"
echo "2) MD5 - RFC 1321"
echo "3) SHA1 - RFC 3174 (FIPS 180-3)"
echo "4) SHA224 - RFC 3874 (FIPS 180-3)"
echo "5) SHA256 - FIPS 180-3"
echo "6) SHA384 - FIPS 180-3"
echo "7) SHA512 - FIPS 180-3"
echo "8) RMD160 - RFC 2857"
echo "9) GOST - RFC 5831"
echo "10)WHIRLPOOL - ISO/IEC 10118-3:2004"
echo "11)LM - Microsoft Windows hash"
echo "12)NTLM - Microsoft Windows hash"
echo "13)MYSQL - MySQL 3, 4, 5 hash"
echo "14)CISCO7 - Cisco IOS type 7 encrypted passwords"
echo "15)JUNIPER - Juniper Networks $9$ encrypted passwords"
echo "16)LDAP_MD5 - MD5 Base64 encoded"
echo "17)LDAP_SHA1 - SHA1 Base64 encoded"
echo ""
read -p "[1-17]: " hashChoice
echo ""
case $hashChoice in
	1) hashOption="MD4"
		echo "Setting the hash to $hashOption"
			break;
	;;
	2) hashOption="MD5"
		echo "Setting the hash to $hashOption"
			break;
			;;
	3) hashOption="SHA1"
		echo "Setting the hash to $hashOption"
			break;
			;;
	4) hashOption="SHA224"
		echo "Setting the hash to $hashOption"
			break;
	;;
	5) hashOption="SHA256"
		echo "Setting the hash to $hashOption"
			break;
	;;
	6) hashOption="SHA384"
		echo "Setting the hash to $hashOption"
			break;
	;;
	7) hashOption="SHA512"
		echo "Setting the hash to $hashOption"
			break;
	;;
	8) hashOption="RMD160"
		echo "Setting the hash to $hashOption"
			break;
	;;
	9) hashOption="GOST"
		echo "Setting the hash to $hashOption"
			break;
	;;
	10) hashOption="WHIRLPOOL"
		echo "Setting the hash to $hashOption"
			break;
	;;
	11) hashOption="LM"
		echo "Setting the hash to $hashOption"
			break;
	;;
	12) hashOption="NTLM"
		echo "Setting the hash to $hashOption"
			break;
	;;
	13) hashOption="MYSQL"
		echo "Setting the hash to $hashOption"
			break;
	;;
	14) hashOption="CISCO7"
		echo "Setting the hash to $hashOption"
			break;
	;;
	15) hashOption="JUNIPER"
		echo "Setting the hash to $hashOption"
			break;
	;;
	16) hashOption="LDAP_MD5"
		echo "Setting the hash to $hashOption"
			break;
	;;
	17) hashOption="LDAP_SHA1"
		echo "Setting the hash to $hashOption"
			break;
	;;
	*) echo "Invalid Input. Please enter valid number [1-5]" 
	;;
esac
done
#finding out what type of lookup (Singular or Multi) to run
echo ""
while true; do
echo "What type of lookup would you like to find?"
echo ""
echo "1) Singular - Lookup one hash."
echo "2) Multi - file containing multiple hashes (one per line)."
echo ""
read -p "[1-2]: " scanChoice
echo ""
case $scanChoice in
	1) 	findHash=1	
		echo "OK easy enough. We will need the hash. NOTE: I don't do any error checking so double check your entry"
		read -p "Hash?: " myHash
				while true; do
		echo "Does " $myHash "look correct? [Y]|[N]"
		read isRight
			case $isRight in
				[yY] |[Yy][Ee][Ss])	
					echo "Wow - good typing congrats. Moving on..."
						break;
				;;		
				[nN]|[Nn][Oo])		
					echo ""
					echo -e "\e[1;31m------------------------------------------------------------------------------------------\e[00m"
					echo "Please re-enter the hash: "
					read myHash
					echo -e "\e[1;31m------------------------------------------------------------------------------------------\e[00m"
					;;	
				*) echo "Invalid Input"
			esac
		done
		break;
		;;
	2) findHash=2
		echo "Please enter the a file containing passwords you would like to test"
		read -p "Path to word list: " hashList
		if [ ! -f "$hashList" ];
		then
		echo "File not found! Please start over."
		else
		break;
		fi
			;;
		*) echo "Invalid Input. Please enter valid number [1-3]" 
	;;
esac
done
}
######################################################################################################################
####################################################################################################################
# Running The Scans
# Reads array and runs scans that are "on"
f_runscan(){

echo ""
echo -e "\e[1;33m Scanning will start in 5 seconds. Please press any key to start now or CTRL C to cancel\e[00m"
read -n1 -t5 any_key
echo ""
echo ""
# using the options from findmyhash help file - thought they were good so why not. Changed the variables to match mine and added authentication options
case $findHash in
	1) echo "Starting to look for" $myHash
	   echo "Depending on the hash this may take a minute or two."
		python /opt/pwnpad/scripts/findmyhash.py $hashOption -h $myHash -g
	;;
	2) echo "Starting a search for the hashes in" $hashList
		echo "Depending on how many are included in the file it may take some time."
		python /opt/pwnpad/scripts/findmyhash.py $hashOption -f $hashList
			;;
esac
echo -e "\e[1;31mScans finished.\e[00m"
}
######################################################################################################################
#####################################################################################################################
# Script Starts
#Tried to put everything in modules so it would be easier to mod sections
f_intro
f_options
f_runscan

