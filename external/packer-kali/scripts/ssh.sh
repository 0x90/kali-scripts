#!/bin/sh

# Most of this script was lifted from https://github.com/jedi4ever/veewee/tree/master/templates/archlinux-x86_64
# and changed to work with packer with my own customizations

# Disable SSH root login
sed -i -e 's/\PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

# Turn on X Forwarding
sed -i -e 's/\#X11Forwarding no/X11Forwarding yes/' /etc/ssh/sshd_config
sed -i -e 's/\#X11DisplayOffset/X11DisplayOffset/' /etc/ssh/sshd_config
sed -i -e 's/\#X11UseLocalhost/X11UseLocalhost/' /etc/ssh/sshd_config
sed -i -e 's/\#AllowTcpForwarding/AllowTcpForwarding/' /etc/ssh/sshd_config

# Turn on public key authentication
sed -i -e 's/\\#Pub/Pub/g' /etc/ssh/sshd_config

