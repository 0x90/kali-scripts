#!/bin/bash

. ask.sh

ask "Do you want to install TOR?" Y || exit 3

echo "# tor repository" >> /etc/apt/sources.list.d/tor.list
echo "deb http://deb.torproject.org/torproject.org wheezy main" >> /etc/apt/sources.list.d/tor.list

gpg --keyserver keys.gnupg.net --recv 886DDD89
gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | sudo apt-key add -
apt-get update
apt-get install -y deb.torproject.org-keyring tor tor-geoipdb polipo vidalia 

mv /etc/polipo/config /etc/polipo/config.orig
wget https://gitweb.torproject.org/torbrowser.git/blob_plain/ae4aa49ad9100a50eec049d0a419fac63a84d874:/build-scripts/config/polipo.conf -O /etc/polipo/config

service tor restart
service polipo restart
update-rc.d tor enable
update-rc.d polipo enable
