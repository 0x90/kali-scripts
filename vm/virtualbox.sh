#!/usr/bin/env bash
#
source ../helper/helper.sh

install_virtualbox(){
    echo "Add VirtualBox repo"
    add_sources "deb http://download.virtualbox.org/virtualbox/debian wheezy contrib" "virtualbox"
#    echo "deb http://download.virtualbox.org/virtualbox/debian wheezy contrib" > /etc/apt/sources.list.d/virtualbox.list

    echo "Add VirtualBox key"
    add_key "https://www.virtualbox.org/download/oracle_vbox.asc"

    apt-get update -y && apt-get install dkms -y && apt-get install virtualbox-4.3 -y
}

install_virtualbox_tools(){
    print_status "Installing VirtualBox Additions"
}