#!/usr/bin/env bash
#
source ../helper/helper.sh


install_chromium(){
    apt-get install -y chromium
    echo "# simply override settings above" >> /etc/chromium/default
    echo 'CHROMIUM_FLAGS="--password-store=detect --user-data-dir"' >> /etc/chromium/default
}

if ask "Do you want to install chromium (and allowing run as root) ?" Y; then
    install_chromium
fi