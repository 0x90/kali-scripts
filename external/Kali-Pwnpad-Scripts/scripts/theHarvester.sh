#!/bin/bash
# Word Press Scanner for pwnpad use by:
# www.securemaryland.org
# @securemaryland
#Tested on Pwnpad Community Edition
# Uses the python tool theHarvester https://code.google.com/p/theharvester/
VERSION="1.0"
###################################################################################################################
# Intro
#
f_intro(){
clear
clear
echo""
# For faster processing you can just assign the insallation directory
# I do a find cause I need to verify where it is
echo "Checking to see if theHarvester is installed. This may take a second or two please be patient."
installdir=/opt/pwnpad/captures/theharvester/
echo ""
echo ""
echo -e "\e[00;32m#############################################################\e[00m"
echo ""
echo "*** theHarvester Scanner script for the Pwnpad Version $VERSION  ***"
echo "*** Author: @securemaryland ***"
echo "*** Launches theHarvester  tool from https://code.google.com/p/theharvester/  ***"
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
echo "1) Basic Scan"
echo "2) Brute Force" 
echo "3) Brute + Shodan"
echo ""
read -p "[1-3]: " scanChoice
echo ""
case $scanChoice in
	1) scanOption="Basic"
		echo "Setting the scan option to $scanOption"
			break;
	;;
	2) scanOption="Brute"
		echo "Setting the scan option to $scanOption. Brute force scanning may take a little longer please be patient."
			break;
			;;
	3) scanOption="Shodan"
		echo "Performing a Brute force w/ Shodan look up. This may take some time so please be patient."
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
# Add the following: /opt/pwnpad/captures/theharvester/* to the capture_files array. 
theharvesterdir=/opt/pwnpad/captures/theharvester
echo -e "\e[1;31m--------------------------------------------------\e[00m"
echo "Setting the output path to "$theharvesterdir" so that they can be included in logwiper script - remember to update it if you haven't."
echo -e "\e[1;31m--------------------------------------------------\e[00m"
read -p  "Enter the reference or client name for the scan: " REF
echo ""
echo "Using the following reference name" $REF
mkdir -p "$theharvesterdir"
if [ ! -d "$theharvesterdir"/"$REF" ]; then
	echo "No directory found for" $REF " creating it now"
	mkdir "$theharvesterdir"/"$REF""$TODAY"
fi
echo "$REF" > "$theharvesterdir"/"$REF""$TODAY"/REF
echo ""
logdir="$theharvesterdir"/"$REF""$TODAY"
}
######################################################################################################################
####################################################################################################################
# Domain to Scan
# Sets the TARGET variable - right now only does one target.
f_target(){
echo -e "\e[1;31m-------------------------------------------------------------------\e[00m"
echo "Please enter the  domain to scan. [e.g. microsoft.com]"
echo " Be sure to include only the domain. Enter the Domain:" 
read TARGET
echo -e "\e[1;31m-------------------------------------------------------------------\e[00m"
echo ""
echo "$TARGET" > "$logdir"/DomainScanned

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
case $scanOption in
	Basic) "theharvester -d $TARGET -b all -f "$logdir"/log.html" 
;;
	Brute) "theharvester -d $TARGET -b All -n -c -t -f "$logdir"/log.html "
	
;;
	Shodan) "theharvester -d $TARGET -b All -n -c -t -h -f "$logdir"/log.html"
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
echo "The following Domain was selected for the scan = "$TARGET"" > "$theharvesterdir"/"$REF""$TODAY"/target.txt
echo "The following options were selected for the scan "$scanOption" with the following authentication setting "$authNeeded"" > "$theharvesterdir"/"$REF""$TODAY"/options.txt
echo ""
echo -e "\e[1;33m------------------------------------------------------------------\e[00m"
echo "Target scanned for - $REF"
echo -e "\e[1;33m------------------------------------------------------------------\e[00m"
echo $TARGET
echo ""
echo -e "\e[1;33m-----------------------------------------------------------------------\e[00m"
cat "$logdir"/log.html |awk -F'</ul>' '{print $1}'|awk -F'</li>' '{$NF=""; print $0}'|awk -F '<li class="useritem">' '{$1=""; print $0}'|sed -e 's/\s\+/\n/g' > tmpemails.txt
grep @ tmpemails.txt >"$logdir"/emails.txt
rm tmpemails.txt
emailfindings=$(cat "$logdir"/emails.txt)
echo "The following emails, if any, can be found in "$logdir"/emails.txt:"
echo -e "\e[00;32m$emailfindings\e[00m"
echo -e "\e[1;33m-----------------------------------------------------------------------\e[00m"
echo ""
echo -e "\e[1;33m-----------------------------------------------------------------------\e[00m"
cat "$logdir"/log.html |awk -F'</ul>' '{print $2}'|awk -F'</li>' '{$NF=""; print $0}'|awk -F '<li class="softitem">' '{$1=""; print $0}'|sed -e 's/\s\+/\n/g' > tmphosts.txt
grep : tmphosts.txt >"$logdir"/hosts.txt
rm tmphosts.txt
hostfindings=$(cat "$logdir"/hosts.txt)
echo "The following hosts, if any, can be found in "$logdir"/hosts.txt:"
echo -e "\e[00;32m$hostfindings\e[00m"
echo -e "\e[1;33m-----------------------------------------------------------------------\e[00m"
echo ""
echo -e "\e[1;33m-----------------------------------------------------------------------\e[00m"
echo "The following can be found in $theharvesterdir"/"$REF""$TODAY"
echo -e "\e[1;33m-----------------------------------------------------------------------\e[00m"
lsFiles=$(ls "$theharvesterdir"/"$REF""$TODAY")
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
