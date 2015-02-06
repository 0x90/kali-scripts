#!/bin/bash
#
source  ../helper/helper.sh

# Install tools for iphone
install_idevice(){
    if ask "Do you want to install tools for work with iDevice?" Y; then
        print_status "Installing tools.."
        apt-get install -y libimobiledevice1 python-imobiledevice usbmuxd iphone-backup-analyzer ipheth-utils ifuse
    fi
}

install_idevice