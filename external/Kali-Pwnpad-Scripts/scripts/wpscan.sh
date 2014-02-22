#!/bin/bash
# Word Press Scanner for pwnpad use by:
# www.securemaryland.org
# @securemaryland
#Tested on Pwnpad Community Edition
# Uses the ruby tool WPSCAN
VERSION="1.0"
###################################################################################################################
# Intro
#
f_intro(){
clear
clear
installdir=/opt/pwnpad/captures/wpscan
echo ""
echo ""
echo -e "\e[00;32m#############################################################\e[00m"
echo ""
echo "*** Word Press Scanner script for the Pwnpad Version $VERSION  ***"
echo "*** Author: @securemaryland ***"
echo "*** Launches the wpscan tool from http://wpscan.org  ***"
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
# Sets the scanOption, authNeeded variable
f_options(){
#moving to the install directory to make sure everything runs ok even if wpscan isn't in the path
cd "$installdir"
# finding out what kind of scan to run
while true; do
echo "What scan option would you like to use?"
echo ""
echo "1) NonIntrusive - Simple scan for basics"
echo "2) Enumerate Plugins" 
echo "3) Eumerate Users"
echo "4) Enermerate Themes"
echo "5) Enermerate Everything"
echo ""
read -p "[1-5]: " scanChoice
echo ""
case $scanChoice in
	1) scanOption="NonIntrusive"
		echo "Setting the scan option to $scanOption"
			break;
	;;
	2) scanOption="OnlyPlugins"
		echo "Setting the scan option to $scanOption"
			break;
			;;
	3) scanOption="OnlyUsers"
		echo "Setting the scan option to $scanOption"
			break;
			;;
	4) scanOption="OnlyThemes"
		echo "Setting the scan option to $scanOption"
			break;
	;;
	5) scanOption="All"
		echo "Setting the scan option to $scanOption"
			break;
	;;
	*) echo "Invalid Input. Please enter valid number [1-4]" 
	;;
esac
done
#finding out if we need authentication and if so which type HTTP/FORM
echo ""
while true; do
echo "Would you like to btuteforce users on $TARGET ?"
echo ""
echo "1) Nope - Just regular scanning is fine."
echo "2) Admin - yes just brute force the admin account."
echo "3) All - yes, please bruteforce all users found."
echo ""
read -p "[1-3]: " authChoice
echo ""
case $authChoice in
	1) 	authNeeded=NO	
		echo "OK easy enough. The scan will proceed without any authentication"
			break;
	;;
	2) authNeeded=Admin
		Adminid="admin"
		echo "It is advised that you use test credentials as this script is not responsible for loss of real credentials"
		echo "Please enter the User Name [default admin]"
		read -p "Adminid: " uid
		echo "Please enter the a wordlist containg passwords you would like to test"
		read -p "Path to word list: " wordlist
		if [ ! -f "$wordlist" ];
		then
		echo "File not found! Please start over."
		else
		break;
		fi
			;;
	3) authNeeded=All
		echo "Please enter the a wordlist containg passwords you would like to test"
		read -p "Path to word list: " wordlist
		if [ ! -f "$wordlist" ];
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
#####################################################################################################################
# Reference Name For Scans
# Sets the REF variable and writes it to the path chosen
# Function complete
f_reference()
{
# Adding wpscan to captures folder so that you can clean it with a simple modification to the pwnpad logwiper script
# Add the following: /opt/pwnpad/captures/wpscan/* to the capture_files array. 
wpscandir=/opt/pwnpad/captures/wpscan
echo -e "\e[1;31m--------------------------------------------------\e[00m"
echo "Setting the output path to "$wpscandir" so that they can be included in logwiper script - remember to update it if you haven't."
echo -e "\e[1;31m--------------------------------------------------\e[00m"
read -p  "Enter the reference or client name for the scan: " REF
echo ""
echo "Using the following reference name" $REF
if [ ! -d "$wpscandir" ]; then
  # Control will enter here and create $nmapdir if it doesn't exist.
  mkdir "$wpscandir"
fi
if [ ! -d "$wpscandir"/"$REF" ]; then
	echo "No directory found for" $REF " creating it now"
	mkdir "$wpscandir"/"$REF""$TODAY"
fi
echo "$REF" > "$wpscandir"/"$REF""$TODAY"/REF
echo ""
}
######################################################################################################################
####################################################################################################################
# URL to Scan
# Sets the TARGET variable - right now only does one target.
f_target()
{
sampleSites=(http://demo.testfire.net 
http://testphp.vulnweb.com 
http://testasp.vulnweb.com 
http://testaspnet.vulnweb.com 
http://zero.webappsecurity.com 
http://crackme.cenzic.com 
http://www.webscantest.com)
i=-1
while true; do
echo -e "\e[1;31m-------------------------------------------------------------------\e[00m"
echo "Please enter the absolute URL to scan. [e.g. http://www.example.com]"
echo "Some good test ones are:"
printf "%s\n" "${sampleSites[@]}"
echo ""
echo "Be sure to include the http:// part." 
read -p "Enter URL: " TARGET
echo -e "\e[1;31m-------------------------------------------------------------------\e[00m"
echo ""
echo -e "\e[1;33mRunning simple ping test to see if $TARGET is up...\e[00m"
pingme=`echo $TARGET |awk -F / '{print $3}'`
ping -c5 $pingme >/dev/null 2>&1
if [ $? = 0 ]
	then
		echo ""
		echo -e "\e[1;33mGreat, the URL: $TARGET appears to be up. Moving on...\e[00m"		
		echo ""
	break;	
	elif [ $? = 1 ]
			then
				echo ""
				echo -e "\e[1;31mSorry, ping test on $TARGET failed. \e[00m"
				echo ""
				echo " Would you like to proceed with $TARGET even though it does not ping? [Y|N]"
				read -p "[Y|N]: " ansYN 
					case $ansYN in
						[yY]|[Yy][Ee][Ss])	
echo ""
echo "OK. Moving on..."
						break;
						;;
						[nN]|[Nn][Oo]) echo""
echo "We will ask you again."
						;;
				esac
		
fi
echo "$TARGET" > "$wpscandir"/"$REF""$TODAY"/URLScanned
done

}
####################################################################################################################
####################################################################################################################
# Running The Scans
# Reads array and runs scans that are "on"
f_runscan(){

echo ""
echo -e "\e[1;33m Scanning will start in 5 seconds. Please press any key to start now or CTRL C to cancel\e[00m"
read -n1 -t5 any_key
echo ""
echo "Scanning started. Depending on the option(s) chosen this may take some time."
echo ""
# using the options from WPscan help file - thought they were good so why not. Changed the variables to match mine and added authentication options
if [ "$authNeeded" == "NO" ];
then
case $scanOption in
	NonIntrusive) wpscan -u $TARGET 
	cp "$installdir"/log.txt "$wpscandir"/"$REF""$TODAY"/log.txt
;;
	OnlyPlugins) wpscan --enumerate p -u $TARGET 
	cp "$installdir"/log.txt "$wpscandir"/"$REF""$TODAY"/log.txt
;;
	OnlyUsers) wpscan --enumerate u -u $TARGET 
	cp "$installdir"/log.txt "$wpscandir"/"$REF""$TODAY"/log.txt
;;
	OnlyThemes) wpscan --enumerate t -u $TARGET 
	cp "$installdir"/log.txt "$wpscandir"/"$REF""$TODAY"/log.txt
;;
	All) wpscan --enumerate p,u,t -u $TARGET 
	cp "$installdir"/log.txt "$wpscandir"/"$REF""$TODAY"/log.txt
;;
esac

elif [ "$authNeeded" == "Admin" ];
then
case $scanOption in
NonIntrusive) wpscan -u $TARGET --username $Adminid --wordlist $wordlist
	cp "$installdir"/log.txt "$wpscandir"/"$REF""$TODAY"/log.txt
;;
	OnlyPlugins) wpscan --enumerate p -u $TARGET --username $Adminid --wordlist $wordlist
	cp "$installdir"/log.txt "$wpscandir"/"$REF""$TODAY"/log.txt
;;
	OnlyUsers) wpscan --enumerate u -u $TARGET --username $Adminid --wordlist $wordlist
	cp "$installdir"/log.txt "$wpscandir"/"$REF""$TODAY"/log.txt
;;
	OnlyThemes) wpscan --enumerate t -u $TARGET --username $Adminid --wordlist $wordlist
	cp "$installdir"/log.txt "$wpscandir"/"$REF""$TODAY"/log.txt
;;
	All) wpscan --enumerate p,u,t -u $TARGET --username $Adminid --wordlist $wordlist
	cp "$installdir"/log.txt "$wpscandir"/"$REF""$TODAY"/log.txt
;;
esac
elif [ "$authNeeded" == "ALL" ];
then
case $scanOption in
	NonIntrusive) wpscan -u $TARGET --wordlist $wordlist
	cp "$installdir"/log.txt "$wpscandir"/"$REF""$TODAY"/log.txt
;;
	OnlyPlugins) wpscan --enumerate p -u $TARGET --wordlist $wordlist
	cp "$installdir"/log.txt "$wpscandir"/"$REF""$TODAY"/log.txt
;;
	OnlyUsers) wpscan --enumerate u -u $TARGET --wordlist $wordlist
	cp "$installdir"/log.txt "$wpscandir"/"$REF""$TODAY"/log.txt
;;
	OnlyThemes) wpscan --enumerate t -u $TARGET --wordlist $wordlist
	cp "$installdir"/log.txt "$wpscandir"/"$REF""$TODAY"/log.txt
;;
	All) wpscan --enumerate p,u,t -u $TARGET --wordlist $wordlist
	cp "$installdir"/log.txt "$wpscandir"/"$REF""$TODAY"/log.txt
;;
esac
fi
echo -e "\e[1;31mScans finished.\e[00m"
}
######################################################################################################################
######################################################################################################################
# Out put
# Builds some outputfiles
f_output() {
sleep 5
echo "The following URL was selected for the scan = "$TARGET"" > "$wpscandir"/"$REF""$TODAY"/target.txt
echo "The following options were selected for the scan "$scanOption" with the following authentication setting "$authNeeded"" > "$wpscandir"/"$REF""$TODAY"/options.txt
echo ""
echo -e "\e[1;33m------------------------------------------------------------------\e[00m"
echo "Target scanned for - $REF"
echo -e "\e[1;33m------------------------------------------------------------------\e[00m"
echo $TARGET
echo ""
echo -e "\e[1;33m-----------------------------------------------------------------------\e[00m"
cat "$wpscandir"/"$REF""$TODAY"/log.txt |grep "[!]" > findings.txt
findings=$(cat findings.txt)
echo "The following possible findings, if any, can be found in "$wpsandir"/"$REF""$TODAY"/findings.txt:"
echo -e "\e[00;32m$findings\e[00m"
echo -e "\e[1;33m-----------------------------------------------------------------------\e[00m"
echo -e "\e[1;33m-----------------------------------------------------------------------\e[00m"
echo "The following can be found in $wpscandir"/"$REF""$TODAY"
echo -e "\e[1;33m-----------------------------------------------------------------------\e[00m"
lsFiles=$(ls "$wpscandir"/"$REF""$TODAY")
echo -e "\e[00;32m$lsFiles\e[00m"
echo ""
}
#####################################################################################################################
#####################################################################################################################
# Script Starts
#Tried to put everything in modules so it would be easier to mod sections
f_intro
f_reference
f_target
f_options
f_runscan
f_output
