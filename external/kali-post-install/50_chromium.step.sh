#!/bin/bash
. ask.sh

ask "Do you want to install chromium (and allowing run as root) ?" Y || exit 3

apt-get install -y chromium
echo "# simply override settings above" >> /etc/chromium/default
echo 'CHROMIUM_FLAGS="--password-store=detect --user-data-dir"' >> /etc/chromium/default
