#!/usr/bin/env bash
#
source ../helper/helper.sh

install_virtualbox(){
echo "Add VB repo"
echo >> /etc/apt/sources.list
echo "deb http://download.virtualbox.org/virtualbox/debian wheezy contrib" >> /etc/apt/sources.list

echo "Add VB key"
wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -

apt-get update -y
apt-get install dkms -y
apt-get install virtualbox-4.3 -y
}

install_virtualbox_tools(){
    print_status "Installing VirtualBox Additions"
}