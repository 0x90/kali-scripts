#!/bin/bash
##########################################################
f_wlan1check(){
adaptor=`ip addr | grep wlan1`

echo "Checking to make sure wlan1 is plugged in..."
sleep 3

if [ -z "$adaptor" ]; then
    echo "This script requies wlan1 to be plugged in."
    echo "I cant see it so exiting now. Try again when wlan1 is plugged in."
exit 1
fi
}
################# START ##################################
f_wlan1check
echo "Everything is good. Starting services and wicd-curses"
sleep 3
service dbus stop
sleep 1
service wicd stop
sleep 1
service dbus start
sleep 2
service wicd start
sleep 2
wicd-curses