#!/bin/bash
# LazyMap for the Pwnpad
# mods and code refinement for pwnpad use by:
# www.securemaryland.org
# @securemaryland
#Tested on Pwnpad Community Edition
# Original LazyMap Author - the one responsible for most of this code:
# Daniel Compton
# www.commonexploits.com
# contact@commexploits.com
# Twitter = @commonexploits
# 19/12/2012
# LazyMap originally Tested on Bactrack 5 only.

VERSION="1.0"
###################################################################################################################
# Intro
#
f_intro(){
clear
echo -e "\e[00;32m#############################################################\e[00m"
echo ""
echo "*** Auto Nmap Script for the Pwnpad Version $VERSION  ***"
echo "*** Author: @securemaryland ***"
echo "*** Code based off of LazyMap from Daniel Compton @commonexploits http://www.commonexploits.com/?p=713   ***"
echo ""
echo -e "\e[00;32m#############################################################\e[00m"
echo ""
echo ""
echo -e "\e[1;33mAll output including hosts up, down, unique ports and an audit of each scan start stop times can be found in the output directory.\e[00m"
echo ""
echo -e "\e[1;33mPress Enter to continue\e[00m"
echo ""
read ENTERKEY
clear
}
#####################################################################################################################
#####################################################################################################################
# User Config Options
# Turn on/off Nmap scan options
# Function Complete - put options in an array is there a better way?
f_options()
{
scanOptions="(FULLTCP SCRIPT QUICKUDP COMMONTCP)"
count=0
while true; do
echo "Would you like to turn on the NMAP scanning options (Off by default)? "
read -p "[Y|N]: " optionsYN
echo ""
echo "In this section we will set the option(s) we will use for scanning."
				echo "FULLTCP # to disable/enable Full TCP Scan"
				echo "SCRIPT # to disable/enable safe script Scan"
				echo "QUICKUDP # to disable/enable quick UDP scan" 
				echo "COMMONTCP # to disable/enabke commong TCP scan"
				echo "Note: the more options the longer the scans will take :)."
				echo ""
case $optionsYN in
	[yY] |[Yy][Ee][Ss])
		for i in "${scanOptions[@]}"
			do
				read -p "Would you like the option ${scanOptions[$count]} truned On?  [Y/N]: " ansYN
				case $ansYN in
					[yY] |[Yy][Ee][Ss]) echo "Turning ${scanOptions[$count]} on"
					scanOptions[$count]=$i+ON
					let count++;;
					[nN]|[Nn][Oo]) scanOptions[$count]=$i+OFF
					let count++;;
					*) echo "I didn't undertand your answer leaving option off"
					scanOptions[$count]=$i+OFF
					let count++;;
				esac
			done
		break;
	;;
	[nN]|[Nn][Oo])
			echo "OK just doing a hostup scan. No further scanning will be performed."
		break;
	;;
	*) echo "Invalid Input" 
	;;
esac
done
}
######################################################################################################################
#####################################################################################################################
# Pick Interface
# Sets INT, IP address, amsk  and date variables
# Function complete
f_interface(){
while true; do
echo
echo "Select the interface you want to use for the scans. (1-4)"
echo
echo "1. [rmnet0] (3G GSM connection)"
echo "2. eth0 (USB ethernet adaptor)"
echo "3. wlan0 (Internal Nexus Wifi - default)"
echo "4. wlan1 (USB TP-Link Wifi adaptor)"
echo
read -p "Which one (1-4)?" intAns
case $intAns in
1) INT=rmnet0;;
2) INT=eth0;;
3) INT=wlan0;;
4) INT=wlan1;;
*) INT=wlan0;;
esac
ifconfig |grep -i -w $INT >/dev/null
if [ $? = 1 ]
then
	echo
	echo "Sorry the interface you entered doesn't exist. Everything plugged in?"
	echo
else
break;
fi
done
LOCAL=$(ifconfig $INT |grep "inet addr:" |cut -d ":" -f 2 |awk '{ print $1 }')
MASK=$(ifconfig |grep -i $LOCAL | grep -i mask: |cut -d ":" -f 4)
echo ""
echo -e "We will be using "$INT" with a source IP address of \e[1;33m"$LOCAL"\e[00m  and with the mask of \e[1;33m"$MASK"\e[00m"
TODAY=`date +%Y%m%d`
 }
######################################################################################################################
#####################################################################################################################
# Reference Name For Scans
# Sets the REF variable and writes it to the path chosen
# Function complete
f_reference(){
# Adding nmap to captures folder so that you can clean it with a simple modification to the pwnpad logwiper script
# Add the following: /opt/pwnpad/captures/nmap/* to thecapture_files array. 
nmapdir=/opt/pwnpad/captures/nmap
echo -e "\e[1;31m--------------------------------------------------\e[00m"
echo "Setting the output path to "$nmapdir" so that they can be included in logwiper script - remember to update it if you haven't."
echo -e "\e[1;31m--------------------------------------------------\e[00m"
read -p  "Enter the reference or client name for the scan: " REF
echo ""
echo "Using the following reference name" $REF
if [ ! -d "$nmapdir" ]; then
  # Control will enter here and create $nmapdir if it doesn't exist.
  mkdir -p "$nampdir"
fi
cd "$nmapdir"
if [ ! -d ./"$REF" ]; then
	echo "No directory found for" $REF " creating it now"
	mkdir ./"$REF"
fi
echo "Changing working directory to" $nmapdir"/"$REF
cd ./"$REF"
echo "$REF" > REF
echo "$INT" > INT
echo ""
}
######################################################################################################################
####################################################################################################################
# IP Address Range To Scans
# Sets the RANGE variable - right now only does IP or file need a way to incorporate hostname.
f_range(){
while true; do
echo -e "\e[1;31m-------------------------------------------------------------------\e[00m"
echo " Setting up the ranage to scan  can either in normal Nmap format 192.168.1.1, 192.168.1.1-10, 192.168.1.1/24"
echo ""
echo "Enter the IP address range or the exact path to an input file:" 
read RANGE
echo -e "\e[1;31m-------------------------------------------------------------------\e[00m"
echo $RANGE |grep "[0-9]" >/dev/null 2>&1
if [ $? = 0 ]
	then
		echo ""
		echo -e "\e[1;33mYou enterted a manual IP or range. Got it thanks.\e[00m"
		echo ""
		break;
	else
		echo ""
		echo -e "\e[1;33mYou entered a file as the input, I will just check I can read it ok...\e[00m"
		cat $RANGE >/dev/null 2>&1
			if [ $? = 1 ]
			then
				echo ""
				echo -e "\e[1;31mSorry I can't read that file, check the path and try again!\e[00m"
				echo ""
		else
			echo ""
			echo -e "\e[1;33mI can read the input file ok, Scan will start soon...\e[00m"
			echo ""
			break;
		fi
fi
done
}
######################################################################################################################
####################################################################################################################
# IP Addresses To Exclude From Scans
# Sets the EXCLUDEANS variable and writes exludetmp (file containg ip addrs to exclude)
f_exclude(){
echo -e "\e[1;31m-----------------------------------------------------------------------------------------------------------\e[00m"
echo "Do you want to exclude any IPs from the scan i.e your Windows host?"
read -p "Enter [Y|N]: " EXCLUDEANS
echo -e "\e[1;31m-----------------------------------------------------------------------------------------------------------\e[00m"
while true; do
case $EXCLUDEANS in
[yY] |[Yy][Ee][Ss])	
			echo ""
			echo -e "\e[1;31m------------------------------------------------------------------------------------------\e[00m"
			echo "Enter the IP addresses to exclude i.e 192.168.1.1, 192.168.1.1-10 - normal nmap format"
			echo -e "\e[1;31m------------------------------------------------------------------------------------------\e[00m"
			read EXCLUDEDIPS
			EXCLUDE="--exclude "$EXCLUDEDIPS""
			echo "$EXCLUDE" > excludetmp
			echo "This following IP addresses were asked to be excluded from the scan = "$EXCLUDEDIPS"" > "$REF""$TODAY"_nmap_hosts_excluded.txt
			break;
			;;
[nN]|[Nn][Oo])
			echo "Ok we wont exclude any IPs."
			EXCLUDE=""
			echo "$EXCLUDE" > excludetmp
			break;
			;;
*) echo "Invalid Input"
esac
done
}
######################################################################################################################
####################################################################################################################
# Checks For Live Hosts
# Sets the HOSTSCOUNT and HOSTSUPCHK variables
f_hostchk(){
echo $RANGE |grep "[0-9]" >/dev/null 2>&1
if [ $? = 0 ]
	then
		echo -e "\e[1;33m$REF - Finding Live hosts via $INT, please wait...\e[00m"
		nmap -e $INT -sP $EXCLUDE -PE -PM -PS21,22,23,25,26,53,80,81,110,111,113,135,139,143,179,199,443,445,465,514,548,554,587,993,995,1025,1026,1433,1720,1723,2000,2001,3306,3389,5060,5900,6001,8000,8080,8443,8888,10000,32768,49152 -PA21,80,443,13306 -vvv -oA "$REF""$TODAY"_nmap_PingScan $RANGE >/dev/null
		cat "$REF""$TODAY"_nmap_PingScan.gnmap |grep "Up" |awk '{print $2}' > "$REF""$TODAY"_hosts_Up.txt
		cat "$REF""$TODAY"_nmap_PingScan.gnmap | grep  "Down" |awk '{print $2}' > "$REF""$TODAY"_hosts_Down.txt
	else
		echo -e "\e[1;33m$REF - Finding Live hosts via $INT, please wait...\e[00m"
		nmap -e $INT -sP $EXCLUDE -PE -PM -PS21,22,23,25,26,53,80,81,110,111,113,135,139,143,179,199,443,445,465,514,548,554,587,993,995,1025,1026,1433,1720,1723,2000,2001,3306,3389,5060,5900,6001,8000,8080,8443,8888,10000,32768,49152 -PA21,80,443,13306 -vvv -oA "$REF""$TODAY"_nmap_PingScan -iL $RANGE >/dev/null
		cat "$REF""$TODAY"_nmap_PingScan.gnmap |grep "Up" |awk '{print $2}' > "$REF""$TODAY"_hosts_Up.txt
		cat "$REF""$TODAY"_nmap_PingScan.gnmap | grep  "Down" |awk '{print $2}' > "$REF""$TODAY"_hosts_Down.txt
		
fi
HOSTSCOUNT=$(cat "$REF""$TODAY"_hosts_Up.txt |wc -l)
HOSTSUPCHK=$(cat "$REF""$TODAY"_hosts_Up.txt)
if [ -z "$HOSTSUPCHK" ]
	then
		echo ""
		echo -e "\e[1;33mIt seems there are no live hosts present in the range specified..I will run a Arp-scan to double check...\e[00m"
		echo ""
		sleep 4
		arp-scan --interface $INT --file "$REF""$TODAY"_hosts_Down.txt > "$REF""$TODAY"_arp_scan.txt 2>&1
		arp-scan --interface $INT --file "$REF""$TODAY"_hosts_Down.txt |grep -i "0 responded" >/dev/null 2>&1
			if [ $? = 0 ]
				then
					echo -e "\e[1;31mNo live hosts were found using arp-scan - check IP range/source address and try again. It may be there are no live hosts.\e[00m"
					echo ""
					rm "INT" 2>&1 >/dev/null
					rm "REF" 2>&1 >/dev/null
					rm "excludetmp" 2>&1 >/dev/null
					touch "$REF""$TODAY"_no_live_hosts.txt
					exit 1
			else
					arp-scan --interface $INT --file "$REF""$TODAY"_hosts_Down.txt > "$REF""$TODAY"_arp_scan.txt 2>&1
					ARPUP=$(cat "$REF""$TODAY"_arp_scan.txt)
					echo ""
					echo -e "\e[1;33mNmap didn't find any live hosts, but apr-scan found the following hosts within the range...script will exit. Try adding these to the host list to scan.\e[00m"
					echo ""
					rm "INT" 2>&1 >/dev/null
					rm "REF" 2>&1 >/dev/null
					rm "excludetmp" 2>&1 >/dev/null
					echo -e "\e[00;32m$ARPUP\e[00m"
					echo ""
					exit 1
	fi
fi
echo -e "\e[1;33m-----------------------------------------------------------------\e[00m"
echo "The following $HOSTSCOUNT hosts were found up for $REF"
echo -e "\e[1;33m-----------------------------------------------------------------\e[00m"
HOSTSUP=$(cat "$REF""$TODAY"_hosts_Up.txt)
echo -e "\e[00;32m$HOSTSUP\e[00m"
echo ""
}
######################################################################################################################
####################################################################################################################
# Running The Scans
# Reads array and runs scans that are "on"
f_runscan(){
echo -e "\e[1;33m Scanning will start in 5 seconds. Please press any key to start now or CTRL C to cancel\e[00m"
read -n1 -t5 any_key
echo "Scanning started. Depending on the options chosen this may take some time."
for X in "${scanOptions[@]}" 
do
if [ "$X" == "FULLTCP+ON" ];
then
# Scanning Full TCP Ports 
echo "Starting Full TCP scan..."
nmap -e $INT -sS $EXCLUDE -PN -T4 -p- -sV --version-intensity 1 -vvv -oA "$REF""$TODAY"_nmap_FullPorts -iL "$REF""$TODAY"_hosts_Up.txt -n
echo "Full TCP Scan complete."
elif [ "$X" == "FULLTCP+OFF" ];
then
echo "Skipping Full TCP scan since it was turned off in the options"
fi
if [ "$X" == "SCRIPT+ON" ];
then
#Script Scan
echo "Starting Script scan..."
nmap -e $INT -PN $EXCLUDE -A -vvv -oA "$REF""$TODAY"_nmap_ScriptScan -iL "$REF""$TODAY"_hosts_Up.txt -n
echo "Script Scan complete."
elif [ "$X" == "SCRIPT+OFF" ];
then
echo "Skipping Script Scan as turned off in options"
fi
if [ "$X" == "QUICKUDP+ON" ];
then
#QUICK UDP Scan (1,000) ports
echo "Starting Quick UDP scan..."
nmap -e $INT -sU $EXCLUDE -Pn -T4 -vvv -oA "$REF""$TODAY"_nmap_QuickUDP -iL "$REF""$TODAY"_hosts_Up.txt -n 
echo "Quick UDP Scan complete."
elif [ "$X" == "QUICKUDP+OFF" ];
then
echo "Skipping Quick UDP Scan as turned off in options"
fi
if [ "$X" == "COMMONTCP+ON" ];
then
#Common TCP Scan
echo "Starting Common TCP scan..."
nmap -e $INT -sS $EXCLUDE -PN -T4 -sV --version-intensity 1 -vvv -oA "$REF""$TODAY"_nmap_CommonPorts -iL "$REF""$TODAY"_hosts_Up.txt -n 
echo "Common TCP Scan complete."
elif [ "$X" == "COMMONTCP+OFF" ];
then
echo "Skipping Common TCP Scan as turned off in options"
fi
done
echo ""
echo -e "\e[1;31mAll scans finished.\e[00m"
}
######################################################################################################################
###################################################################################################################
# Clean UP
# Removes temp files used. Note does not remove scan data. Use Logwiper (if you modified it) or manual deletes to clean scan info
f_cleanup(){
sleep 5
rm "INT" 2>&1 >/dev/null
rm "REF" 2>&1 >/dev/null
rm "excludetmp" 2>&1 >/dev/null
}
#####################################################################################################################
######################################################################################################################
# Out put
# Builds files start/stop times, etc.
f_output() {
sleep 5
echo ""
echo -e "\e[1;33m----------------------------------------------------------------------------------\e[00m"
echo "The following scan start/finish times were recorded for $REF"
echo -e "\e[1;33m----------------------------------------------------------------------------------\e[00m"
echo ""
PINGTIMESTART=`cat "$REF""$TODAY"_nmap_PingScan.nmap |grep -i "scan initiated" | awk '{ print $6 ,$7 ,$8, $9, $10}'`
PINGTIMESTOP=`cat "$REF""$TODAY"_nmap_PingScan.nmap |grep -i "nmap done" | awk '{ print $5, $6 ,$7 , $8, $9}'`
for x in "${scanOptions[@]}" 
do
if [ "$x" == "FULLTCP+ON" ];
then
FULLTCPTIMESTART=`cat "$REF""$TODAY"_nmap_FullPorts.nmap |grep -i "scan initiated" | awk '{ print $6 ,$7 ,$8, $9, $10}'`
FULLTCPTIMESTOP=`cat "$REF""$TODAY"_nmap_FullPorts.nmap |grep -i "nmap done" | awk '{ print $5, $6 ,$7 , $8, $9}'`
elif [ "$x" == "COMMONTCP+ON" ];
then
COMMONTCPTIMESTART=`cat "$REF""$TODAY"_nmap_CommonPorts.nmap |grep -i "scan initiated" | awk '{ print $6 ,$7 ,$8, $9, $10}'`
COMMONTCPTIMESTOP=`cat "$REF""$TODAY"_nmap_CommonPorts.nmap |grep -i "nmap done" | awk '{ print $5, $6 ,$7 , $8, $9}'`
elif [ "$x" == "QUICKYDP+ON" ];
then
QUICKUDPTIMESTART=`cat "$REF""$TODAY"_nmap_QuickUDP.nmap |grep -i "scan initiated" | awk '{ print $6 ,$7 ,$8, $9, $10}'`
QUICKUDPTIMESTOP=`cat "$REF""$TODAY"_nmap_QuickUDP.nmap |grep -i "nmap done" | awk '{ print $5, $6 ,$7 , $8, $9}'`
elif [ "$x" == "SCRIPT+ON" ];
then
SCRIPTTIMESTART=`cat "$REF""$TODAY"_nmap_ScriptScan.nmap |grep -i "scan initiated" | awk '{ print $6 ,$7 ,$8, $9, $10}'`
SCRIPTTIMESTOP=`cat "$REF""$TODAY"_nmap_ScriptScan.nmap |grep -i "nmap done" | awk '{ print $5, $6 ,$7 , $8, $9}'`
fi
done

if [ -z "$PINGTIMESTOP" ]
	then
		echo ""
		echo "" >> "$REF""$TODAY"_nmap_scan_times.txt
		echo -e "\e[1;33mPing sweep started $PINGTIMESTART\e[00m - \e[1;31mscan did not complete or was interupted!\e[00m"
		echo "Ping sweep started $PINGTIMESTART - scan did not complete or was interupted!" >> "$REF""$TODAY"_nmap_scan_times.txt
	else
		echo ""
		echo "" >> "$REF""$TODAY"_nmap_scan_times.txt
		echo -e "\e[1;33mPing sweep started $PINGTIMESTART\e[00m - \e[00;32mfinished successfully $PINGTIMESTOP\e[00m"
		echo "Ping sweep started $PINGTIMESTART - finsihed successfully $PINGTIMESTOP" >> "$REF""$TODAY"_nmap_scan_times.txt
fi
if [ -z "$COMMONTCPTIMESTOP" ]
	then
		echo ""
		echo "" >> "$REF""$TODAY"_nmap_scan_times.txt
		echo -e "\e[1;33mCommon TCP scan started $COMMONTCPTIMESTART\e[00m - \e[1;31mscan did not complete or was interupted!\e[00m"
		echo "Common TCP scan started $COMMONTCPTIMESTART - Scan option not turned on" >> "$REF""$TODAY"_nmap_scan_times.txt
	else
		echo ""
		echo "" >> "$REF""$TODAY"_nmap_scan_times.txt
		echo -e "\e[1;33mCommon TCP scan started $COMMONTCPTIMESTART\e[00m - \e[00;32mfinished successfully $COMMONTCPTIMESTOP\e[00m"
		echo "Common TCP scan started $COMMONTCPTIMESTART - finished successfully $COMMONTCPTIMESTOP" >> "$REF""$TODAY"_nmap_scan_times.txt
fi
if [ -z "$FULLTCPTIMESTOP" ]
	then
		echo ""
		echo "" >> "$REF""$TODAY"_nmap_scan_times.txt
		echo -e "\e[1;33mFull TCP scan started $FULLTCPTIMESTART\e[00m - \e[1;31mscan did not complete or was interupted!\e[00m"
		echo "Full TCP scan started $FULLTCPTIMESTART - Scan option not turned on" >> "$REF""$TODAY"_nmap_scan_times.txt
	else
		echo ""
		echo "" >> "$REF""$TODAY"_nmap_scan_times.txt
		echo -e "\e[1;33mFull TCP scan started $FULLTCPTIMESTART\e[00m - \e[00;32mfinished successfully $FULLTCPTIMESTOP\e[00m"
		echo "Full TCP scan started $FULLTCPTIMESTART - finished successfully $FULLTCPTIMESTOP" >> "$REF""$TODAY"_nmap_scan_times.txt
fi
if [ -z "$QUICKUDPTIMESTOP" ]
	then
		echo ""
		echo "" >> "$REF""$TODAY"_nmap_scan_times.txt
		echo -e "\e[1;33mQuick UDP scan started $QUICKUDPTIMESTART\e[00m - \e[1;31mscan did not complete or was interupted!\e[00m"
		echo "Quick UDP scan started $QUICKUDPTIMESTART - Scan option not turned on" >> "$REF""$TODAY"_nmap_scan_times.txt
	else
		echo ""
		echo "" >> "$REF""$TODAY"_nmap_scan_times.txt
		echo -e "\e[1;33mQuick UDP scan started $QUICKUDPTIMESTART\e[00m - \e[00;32mfinished successfully $QUICKUDPTIMESTOP\e[00m"
		echo "Quick UDP scan started $QUICKUDPTIMESTART - finished successfully $QUICKUDPTIMESTOP" >> "$REF""$TODAY"_nmap_scan_times.txt
fi
if [ -z "$SCRIPTTIMESTOP" ]
	then
		echo ""
		echo "" >> "$REF""$TODAY"_nmap_scan_times.txt
		echo -e "\e[1;33mScript scan started $SCRIPTTIMESTART\e[00m - \e[1;31mscan did not complete or was interupted!\e[00m"
		echo "Script scan started $SCRIPTTIMESTART - Scan option not turned on" >> "$REF""$TODAY"_nmap_scan_times.txt
	else
		echo ""
		echo "" >> "$REF""$TODAY"_nmap_scan_times.txt
		echo -e "\e[1;33mScript scan started $SCRIPTTIMESTART\e[00m - \e[00;32mfinished successfully $SCRIPTTIMESTOP\e[00m"
		echo "Script scan started $SCRIPTTIMESTART - finished successfully $SCRIPTTIMESTOP" >> "$REF""$TODAY"_nmap_scan_times.txt
fi
echo ""
echo -e "\e[1;33m------------------------------------------------------------------\e[00m"
echo "Unique TCP and UDP Port Summary - $REF"
echo -e "\e[1;33m------------------------------------------------------------------\e[00m"
UNIQUE=$(cat *.xml |grep -i 'open"' |grep -i "portid=" |cut -d '"' -f 4,5,6| grep -o '[0-9]*' |sort --unique |paste -s -d,)
echo $UNIQUE >"$REF""$TODAY"_nmap_unique_ports.txt
echo -e "\e[00;32m$UNIQUE\e[00m"
echo ""
echo -e "\e[1;33m-----------------------------------------------------------------------\e[00m"
echo "The following $HOSTSCOUNT hosts were up and scanned for $REF"
echo -e "\e[1;33m-----------------------------------------------------------------------\e[00m"
HOSTSUP=$(cat "$REF""$TODAY"_hosts_Up.txt)
echo -e "\e[00;32m$HOSTSUP\e[00m"
echo ""
echo -e "\e[1;33m-----------------------------------------------------------------------\e[00m"
echo "The following files can be found in $nmapdir/$REF"
echo -e "\e[1;33m-----------------------------------------------------------------------\e[00m"
lsFiles=$(ls "$nmapdir"/"$REF")
echo -e "\e[00;32m$lsFiles\e[00m"
echo ""
}
#####################################################################################################################
#####################################################################################################################
# Script Starts
#Tried to put everything in modules so it would be easier to mod sections
f_intro
f_interface
f_reference
f_options
f_range
f_exclude
f_hostchk
f_runscan
f_output
f_cleanup

