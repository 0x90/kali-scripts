#!/bin/bash
#######################################################
# Check for handshaker install
#######################################################
f_check_handshaker(){
# create folder handshaker or check if one exsists
mkdir -p "/opt/pwnpad/captures/handshaker"
# check for handhsaker install. if not then download
if [ ! -f /usr/bin/handshaker ]; then
	echo "Downloading handshaker..."
	sleep 3
	wget https://raw.github.com/binkybear/HandShaker/master/handshaker.sh
	apt-get -y install beep
	echo "Copying to /usr/bin/handshaker"
	sleep 2
	cp handshaker.sh /usr/bin/handshaker
	chmod +x /usr/bin/handshaker
	rm handshaker.sh
fi
}
#######################################################
# Function to check for wlan1 and set up monitoring
#######################################################
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
}
#######################################################
# Start Handshaker
#######################################################
f_start(){
echo "Handhsaker autobot on wlan1"
handshaker -a  -i wlan1 -o /opt/pwnpad/captures/handshaker;
}
#######################################################
clear
f_check_handshaker
f_start