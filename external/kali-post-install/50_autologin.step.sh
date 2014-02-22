#!/bin/bash
. ask.sh

ask "Do you want to auto login on startup?" Y || exit 3

sed -i 's,#  Automatic,Automatic,g' /etc/gdm3/daemon.conf
