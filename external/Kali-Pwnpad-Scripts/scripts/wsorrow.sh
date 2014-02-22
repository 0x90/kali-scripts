#!/bin/bash
# Word Press Scanner for pwnpad use by:
# www.securemaryland.org
# @securemaryland
#Tested on Pwnpad Community Edition
# Uses the perl tool Web-Sorrow
VERSION="1.0"
installdir=/opt/pwnpad/websorrow

###################################################################################################################
# Intro
#
f_intro(){
clear
echo ""
echo ""
echo -e "\e[00;32m#############################################################\e[00m"
echo ""
echo "*** Web-Sorrow Scanner script for the Pwnpad Version $VERSION  ***"
echo "*** Author: @securemaryland ***"
echo "*** Launches the Web-Sorrow tool from https://code.google.com/p/web-sorrow/  ***"
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
echo "1) Standard Scanning"
echo "2) Intense Scanning (run everything)" 
echo "3) Stealthy scan (ninja)"
echo ""
read -p "[1-3]: " scanChoice
echo ""
case $scanChoice in
	1) scanOption="Standard"
		echo "Setting the scan option to $scanOption"
			break;
	;;
	2) scanOption="Intense"
		echo "Setting the scan option to $scanOption"
			break;
	;;
	3) scanOption="Stealthy"
		echo "Setting the scan option to $scanOption"
			break;
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
f_reference(){
# Adding wpscan to captures folder so that you can clean it with a simple modification to the pwnpad logwiper script
# Add the following: /opt/pwnpad/captures/wsorrow/* to the capture_files array. 
wsorrowdir=/opt/pwnpad/captures/wsorrow
echo -e "\e[1;31m--------------------------------------------------\e[00m"
echo "Setting the output path to "$wsorrowdir" so that they can be included in logwiper script - remember to update it if you haven't."
echo -e "\e[1;31m--------------------------------------------------\e[00m"
read -p  "Enter the reference or client name for the scan: " REF
echo ""
echo "Using the following reference name" $REF
mkdir -p "$wsorrowdir"
if [ ! -d "$wsorrowdir"/"$REF" ]; then
	echo "No directory found for" $REF " creating it now"
	mkdir "$wsorrowdir"/"$REF""$TODAY"
fi
echo "$REF" > "$wsorrowdir"/"$REF""$TODAY"/REF
echo ""
}
######################################################################################################################
####################################################################################################################
# URL to Scan
# Sets the TARGET variable - right now only does one target.
f_target(){
sampleSites=(http://demo.testfire.net http://testphp.vulnweb.com http://testasp.vulnweb.com http://testaspnet.vulnweb.com http://zero.webappsecurity.com http://crackme.cenzic.com http://www.webscantest.com)
while true; do
echo -e "\e[1;31m-------------------------------------------------------------------\e[00m"
echo "Please enter the absolute URL to scan. [e.g. http://www.example.com]"
echo "Some good test ones are:"
printf "%s\n" "${sampleSites[@]}"
echo " Be sure to include the http:// part. Enter the URL:" 
read TARGET
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
				read -p "[Y|N]: " 
					case $ansYN in
						[yY] |[Yy][Ee][Ss])	echo " OK. Moving on..."
						break;
						;;
						[nN]|[Nn][Oo]) echo "We will ask you again."
						;;
					esac
		
fi
echo "$TARGET" > "$wsorrowdir"/"$REF""$TODAY"/URLScanned
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

case $scanOption in
	Standard) perl "$installdir"/Wsorrow.pl -host $TARGET -S -Fd  |t tee log$REF$TODAY
	mv log$REF$TODAY $wsorrowdir/"$REF""$TODAY"/
	;;
	Intense) perl "$installdir"/Wsorrow.pl -host $TARGET -intense |t tee log$REF$TODAY
	mv log$REF$TODAY $wsorrowdir/"$REF""$TODAY"/
;;
	Stealthy) perl "$installdir"/Wsorrow.pl -host $TARGET -ninja |t tee log$REF$TODAY
	mv log$REF$TODAY $wsorrowdir/"$REF""$TODAY"/
;;
esac


echo -e "\e[1;31mScans finished.\e[00m"
}
######################################################################################################################
######################################################################################################################
# Out put
# Builds some outputfiles
f_output() {
sleep 5
echo "The following URL was selected for the scan = "$TARGET"" > "$wsorrowdir"/"$REF""$TODAY"/target.txt
echo "The following options were selected for the scan "$scanOption" with the following authentication setting "$authNeeded"" > "$wsorrowdir"/"$REF""$TODAY"/options.txt
echo ""
echo -e "\e[1;33m------------------------------------------------------------------\e[00m"
echo "Target scanned for - $REF"
echo -e "\e[1;33m------------------------------------------------------------------\e[00m"
echo $TARGET
echo ""
echo -e "\e[1;33m-----------------------------------------------------------------------\e[00m"
echo "The following can be found in $wsorrowdir"/"$REF""$TODAY"
echo -e "\e[1;33m-----------------------------------------------------------------------\e[00m"
lsFiles=$(ls "$wsorrowdir"/"$REF""$TODAY")
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
