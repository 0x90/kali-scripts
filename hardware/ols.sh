#!/usr/bin/env bash
#
source ../helper/helper.sh

apt-get install libsigrok0-dev sigrok libsigrokdecode0-dev -y

#SIGROK
apt-get install git-core gcc make autoconf automake libtool
git clone git://sigrok.org/libserialport
$ cd libserialport
$ ./autogen.sh
$ ./configure
$ make
$ sudo make install

apt-get install git-core gcc g++ make autoconf autoconf-archive \
  automake libtool pkg-config libglib2.0-dev libglibmm-2.4-dev libzip-dev \
  libusb-1.0-0-dev libftdi-dev check doxygen python-numpy\
  python-dev python-gi-dev python-setuptools swig default-jdk


$ git clone git://sigrok.org/libsigrok
$ cd libsigrok
$ ./autogen.sh
$ ./configure
$ make
$ sudo make install


# SIGROK GUI
sudo apt-get install cmake libqt4-dev libboost-dev libboost-test-dev libboost-thread-dev libboost-system-dev
apt-get install git-core g++ make cmake libtool pkg-config \
  libglib2.0-dev libqt4-dev libboost-test-dev libboost-thread-dev\
  libboost-filesystem-dev libboost-system-dev

git://sigrok.org/pulseview.git
