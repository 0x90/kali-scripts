#!/bin/sh
# https://forums.kali.org/showthread.php?25715-How-to-install-Wifite-mod-pixiewps-and-reaver-wps-fork-t6x-to-nethunter

cd ~
mkdir backup
cd backup
git clone https://github.com/derv82/wifite.git
git clone https://github.com/aanarchyy/wifite-mod-pixiewps.git
git clone https://github.com/t6x/reaver-wps-fork-t6x.git
git clone https://github.com/wiire/pixiewps.git
apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y
sudo apt-get install libpcap-dev aircrack-ng sqlite3 libsqlite3-dev libssl-dev -y
cd pixiewps/src/
make && make install
cd /root/backup/reaver-wps-fork-t6x/src/
./configure
make && make install
cp /root/backup/wifite/wifite.py /usr/bin/wifite
chmod +x /usr/bin/wifite
cp /root/backup/wifite-mod-pixiewps/wifite-ng /usr/bin/wifite-ng
chmod +x /usr/bin/wifite-ng
