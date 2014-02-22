#!/bin/bash

## date format ##
NOW=$(date +"%m-%d-%y-%H%M%S")

# create database folder or check if one exsists
mkdir -p "/opt/pwnpad/captures/kismet_db"

# process all netxml files

cd /opt/pwnpad/captures/kismet/
for capture in $(find . -iname '*.netxml'); do
echo "Adding $capture to datbase"
sleep 5
giskismet -x "$capture" --database "/opt/pwnpad/captures/kismet_db/wireless.dbl"

done

# export kml of all wireless data and copy files to sdcard

giskismet --database "/opt/pwnpad/captures/kismet_db/wireless.dbl" -q "select * from wireless" -o "/opt/pwnpad/captures/kismet/kismet-$NOW.kml"
echo "Created kismet-$NOW.kml file for Google Earth"
cd /sdcard/
zip -rj "kismet-captures-$NOW.zip" /opt/pwnpad/captures/kismet/
echo "Successfully copied to /sdcard/kismet-captures-$NOW.zip"

# option to erase files

read -p "Would you like to erase all files in Kismet folder? (y/n)" CONT
if [ "$CONT" == "y" ]; then
	echo "Removing capture files..."
	wipe -f -i -r /opt/pwnpad/captures/kismet/*
else
  echo "All files copied successfully!";
fi
exit
