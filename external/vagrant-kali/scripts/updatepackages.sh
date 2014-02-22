#!/bin/sh

sudo -s sh <<EOF

echo *************************************************************************
echo [+] Updating and upgrading all packages
echo *************************************************************************
sleep 3;

apt-get update && apt-get upgrade -y

EOF

