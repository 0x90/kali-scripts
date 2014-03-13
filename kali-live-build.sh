#!/bin/sh

#OR BUILD YOUR OWN CUSTOM ISO.
apt-get install git live-build cdebootstrap
git clone git://git.kali.org/live-build-config.git
cd live-build-config
lb config
lb build

