#!/usr/bin/env bash
#
source ../helper/helper.sh

if ask "Do you want to install the flash player?" Y; then
    apt-get -y install flashplugin-nonfree
fi

if ask "Do you want to install OWASP Mantra browser?" Y; then
    apt-get install -y owasp-mantra-ff
fi



