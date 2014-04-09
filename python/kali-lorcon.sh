#!/bin/sh
# Latest version of Pylorcon2 https://github.com/tom5760/pylorcon2
#

echo "Installing Lorcon dependecies"
apt-get install libpcap0.8-dev libnl-dev

#Requires lorcon2:
echo "Installing Lorcon"
cd /usr/src
git clone https://code.google.com/p/lorcon
cd lorcon
./configure
make
make install

# install pylorcon. Deprecated?
#echo "Install pylorcon"
#cd /usr/src
#svn checkout http://pylorcon.googlecode.com/svn/trunk/ pylorcon
#cd pylorcon
#python setup.py build
#python setup.py install


# install pylorcon2
echo "Install pylorcon2"
cd /usr/src
svn checkout http://pylorcon2.googlecode.com/svn/trunk/ pylorcon2
cd pylorcon2
python setup.py build
python setup.py install

# to make lorcon available to metasploit
#cd ../ruby-lorcon/
#ruby extconf.rb
#make
#make install
