#!/bin/sh

# Install and set up VirtualBox Guest Additions
cd /root
mkdir vbox
mount VBoxGuestAdditions.iso vbox/
cd vbox
./VBoxLinuxAdditions.run
cd ..
umount vbox
rm -rf vbox VBoxGuestAdditions.iso

