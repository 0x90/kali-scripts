#!/bin/bash

# Turn on X Forwarding
sed -i -e 's/\#X11Forwarding no/X11Forwarding yes/' /etc/ssh/sshd_config
sed -i -e 's/\#X11DisplayOffset/X11DisplayOffset/' /etc/ssh/sshd_config
sed -i -e 's/\#X11UseLocalhost/X11UseLocalhost/' /etc/ssh/sshd_config
sed -i -e 's/\#AllowTcpForwarding/AllowTcpForwarding/' /etc/ssh/sshd_config



