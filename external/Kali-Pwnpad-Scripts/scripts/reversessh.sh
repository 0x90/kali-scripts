#!/bin/bash
# Author: grep@rocketbearlabs.com
# grep8000.blogspot.com
# Revision: 4.12.2011

#check for rsa key, if not there generate and continue

ls -a /root/.ssh/id_rsa |grep id_rsa > ssh_key_status

# Have keys

if [ -s ssh_key_status ]
        then
echo Enter address for reverse ssh shell example.dyndns.org

read dnsname

echo Enter the port the ssh server is running on:

read port

# Set variables

SSH_receiver=$dnsname
SSH_receiver_port=$port
SSH_user=root
SSH_key="/root/.ssh/id_rsa"

status=`ps ax |grep -v grep |grep -o "ssh -NR"`

if [ "$status" == "ssh -NR" ] ; then echo connected ; else ssh -NR 3333:localhost:22 -i "$SSH_key" "$SSH_user"@"$SSH_receiver" -p "$SSH_receiver_port"; fi


# Generate keys if none found

else 

	echo "				"

	echo Please hit enter for each step

	ssh-keygen -t rsa

echo "                              "

echo Enter address for reverse ssh shell example.dyndns.org

read dnsname

# Set variables
SSH_receiver=$dnsname
SSH_receiver_port=443
SSH_user=root
SSH_key="/root/.ssh/id_rsa"

status=`ps ax |grep -v grep |grep -o "ssh -NR"`

if [ "$status" == "ssh -NR" ] ; then echo connected ; else ssh -NR 

3333:localhost:22 -i "$SSH_key" "$SSH_user"@"$SSH_receiver" -p 

"$SSH_receiver_port"; fi

fi
