#!/bin/bash

wget http://blog.anantshri.info/content/uploads/2010/09/add-apt-repository.sh.txt
cp add-apt-repository.sh.txt /usr/sbin/add-apt-repository
chmod o+x /usr/sbin/add-apt-repository
chown root:root /usr/sbin/add-apt-repository
