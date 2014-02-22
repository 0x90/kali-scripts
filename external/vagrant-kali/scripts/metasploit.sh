#!/bin/sh

sudo -s sh <<EOF

echo *************************************************************************
echo [+] Enabling Metasploit services. Updating Metasploit database.
echo *************************************************************************
sleep 3;

update-rc.d postgresql enable
update-rc.d metasploit enable

service postgresql start
service metasploit start

msfupdate

EOF

