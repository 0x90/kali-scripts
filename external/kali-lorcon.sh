#!/bin/sh

# lorcon2:
apt-get install libpcap0.8-dev libnl-dev
cd /usr/src
git clone https://code.google.com/p/lorcon
cd lorcon
./configure
make
make install

# install pylorcon
cd /usr/src
svn checkout http://pylorcon2.googlecode.com/svn/trunk/ pylorcon2
cd pylorcon2
python setup.py build
python setup.py install

# to make lorcon available to metasploit
#https://github.com/pwnieexpress/metasploit-framework/tree/master/external/ruby-lorcon
#cd ../ruby-lorcon/
#ruby extconf.rb
#make
#make install
