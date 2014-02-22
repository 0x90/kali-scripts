#!/bin/bash

. ask.sh

ask "Do you want to install armitage (and postgres/metasploit on boot)?" Y || exit 3

update-rc.d postgresql enable && update-rc.d metasploit enable

service postgresql start

apt-get install -y armitage
service metasploit stop
service metasploit start

msfupdate

echo exit > /tmp/msf.rc
msfconsole -r /tmp/msf.rc
rm /tmp/msf.rc

git clone git://github.com/ChrisTruncer/Veil.git /usr/share/veil/
