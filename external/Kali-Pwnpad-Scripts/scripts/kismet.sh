#!/bin/bash

echo "Make sure BlueNMEA is running before starting with GPS support"
sleep 3
cd /opt/pwnpad/scripts
read -p "Would you like to run Kismet with GPS enabled? (y/n)" CONT
if [ "$CONT" == "y" ]; then
	(socat TCP:127.0.0.1:4352 PTY,link=/tmp/gps & gpsd /tmp/gps) & kismet;
	killall gpsd
	./giskismet.sh;
	wipe -f -P 5 /tmp/gps
else
  echo "Running Kismet WITHOUT GPS support..."
  sleep 2
  kismet;
  clear
fi
exit