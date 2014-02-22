#!/bin/bash
. ask.sh

ask "Do you want to install fresh sshd/ssh keys? (might be good if you're using the vmware image)" Y || exit 3

mkdir /etc/ssh/default_kali_keys
mv /etc/ssh/ssh_host* /etc/ssh/default_kali_keys/

dpkg-reconfigure openssh-server

echo
echo "please make sure that those keys differ"
echo 

md5sum /etc/ssh/default_kali_keys/*
md5sum /etc/ssh/ssh_host*

echo

service ssh try-restart

ssh-keygen -t rsa -b 2048

echo "Enabling visual hostkeys in your .ssh/config"
echo "VisualHostKey=yes" >> ~/.ssh/config
