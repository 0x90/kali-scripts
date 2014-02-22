#!/bin/sh

# Setup vagrant user 
# This depends on having the virtualbox-guest-additions package installed

useradd -m -G sudo,vboxsf -r vagrant
chsh -s /bin/bash vagrant
cd /home/vagrant
mkdir -m 700 .ssh
wget https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub
mv vagrant.pub .ssh/authorized_keys
chmod 600 .ssh/authorized_keys
chown -R vagrant:vagrant .ssh

