#!/bin/bash
. ask.sh

ask "Do you want to install the flash player?" Y || exit 3

apt-get -y install flashplugin-nonfree
