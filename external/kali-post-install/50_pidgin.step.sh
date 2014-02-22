#!/bin/bash
. ask.sh

ask "Do you want to install pidgin and an OTR chat plugin?" Y || exit 3

apt-get -y install pidgin pidgin-otr
