#!/bin/bash

. ask.sh

ask "Do you want to configure /var/www/tools?" Y || exit 3

apt-get -y install windows-binaries
mkdir -p /var/www/tools/shells && chmod -R 755 /var/www/tools
cp /usr/share/windows-binaries/{nc.exe,plink.exe,vncviewer.exe,wget.exe} /var/www/tools/
wget -c http://winscp.net/download/winscp514.zip -O /tmp/winscp514.zip && unzip /tmp/winscp514.zip
cp /tmp/WinSCP.exe /var/www/tools/scp.exe
rm /tmp/winscp*
rm /tmp/readme.txt
rm /tmp/WinSCP*
