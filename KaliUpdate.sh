#!/bin/bash

#A huge thanks to Joshua from Top-hat-sec for helping me code this script
#Visit and become a member of Top-hat-sec.com forums! We have a great community.

clear
#DEFINED COLOR SETTINGS
RED=$(tput setaf 1 && tput bold)
GREEN=$(tput setaf 2 && tput bold)
STAND=$(tput sgr0)
BLUE=$(tput setaf 6 && tput bold)



echo ""
echo ""
echo ""
echo $RED"              +##############################################+"
echo $RED"              +      em3rgency's Kali Linux Update Script    +"
echo $RED"              +                                              +"
echo $RED"              +                  Version 1.1                 +"
echo $RED"              +                                              +"
echo $RED"              +               www.em3rgency.com              +"
echo $RED"              +##############################################+"
echo ""
echo $BLUE"     Visit http://www.em3rgency.com for updates to this script. Thanks"
echo ""
echo $BLUE"        This script will perform various updates and configure Kali "$STAND
sleep 3
clear



echo $RED"               ====== Updating System from standard repos ======"
#Update system
apt-get update
apt-get -y upgrade 
echo ""
clear

#dmi=`dmesg | grep DMI:`
#if [[ "$dmi" ==  *VMWare* ]]; then
#	echo $RED "====== Installing VMWare Guest Tools."

#	echo cups enabled >> /usr/sbin/update-rc.d
#	echo vmware-tools enabled >> /usr/sbin/update-rc.d
#
#	apt-get install gcc make linux-headers-$(uname -r)
#	ln -s /usr/src/linux-headers-$(uname -r)/include/generated/uapi/linux/version.h /usr/src/linux-headers-$(uname -r)/include/linux/
#
#	apt-get install xserver-xorg-input-vmmouse
#	echo $RED""
#	echo $RED" -- System ready for VMware guest tools. Install manualy."
#	sleep 5
#	clear
#fi

#Install VirtualBox tools
#dmi=`dmesg | grep DMI:`
#if [[ "$dmi" ==  *VirtualBox* ]]; then
#	echo " VirtualBox Guest"
#	apt-get install linux-headers-$(uname -r)
#	echo $RED""
#	echo $RED"-=-=-=- System ready for Guest Additions. Run VirtualBox Guest Additions manualy."
#	sleep 5
#	clear
#fi

#Continue other installs

echo $RED "                          ====== Fixing wash ======"
#FIX wash
apt-get -y install libsqlite3-dev &>/dev/null
mkdir -p /etc/reaver &>/dev/null
echo $GREEN"                             ====== SUCCESS ======"
sleep 2
echo ""

echo $RED "                      ====== Installing Nautilus ======"
# This will install Nautilus right click open in terminal
apt-get install nautilus-open-terminal -y &>/dev/null
echo $GREEN"                             ====== SUCCESS ======"
sleep 2
echo ""

echo $RED "                        ====== Installing Flash ======"
# Install Flash
apt-get -y install flashplugin-nonfree &>/dev/null
echo $BLUE " Updating flash plugin......" &>/dev/null
update-flashplugin-nonfree --install &>/dev/null
echo $GREEN"                             ====== SUCCESS ======"
sleep 2
echo ""

echo $RED "              ====== Installing Synaptic Package Manager ======"
# This will install Synaptic Package Manager
apt-get install synaptic -y &>/dev/null
echo $GREEN"                             ====== SUCCESS ======"
sleep 2
echo ""

# This will remove the annoying Mail icon "only" from the menu bar
apt-get remove indicator-me indicator-messages -y &>/dev/null
sleep 2



# Install unicornscan. Test if its there cause we dont want to install twice
apt-get install flex &>/dev/null
if [ ! -f /usr/local/bin/unicornscan ]; then
	echo $RED "                     ====== Installing Unicornscan ======"
	cd /root/ &>/dev/null
	wget -N http://unicornscan.org/releases/unicornscan-0.4.7-2.tar.bz2 &>/dev/null
	bzip2 -cd unicornscan-0.4.7-2.tar.bz2 | tar xf - &>/dev/null
	cd unicornscan-0.4.7/ &>/dev/null
	./configure CFLAGS=-D_GNU_SOURCE && make && make install &>/dev/null
	cd /root/ &>/dev/null
fi
sleep 2
echo ""


#Add bleeding edge repository, if it's not there
out=`grep  "kali-bleeding-edge" /etc/apt/sources.list` &>/dev/null
if [[ "$out" !=  *kali-bleeding-edge* ]]; then &>/dev/null
	echo $RED "             ====== Adding Bleeding Edge repo and updating ======"
	echo "" >> /etc/apt/sources.list &>/dev/null
	echo '# Bleeding Edge Repo - added by em3rgencys script' >> /etc/apt/sources.list &>/dev/null
	echo 'deb http://repo.kali.org/kali kali-bleeding-edge main' >> /etc/apt/sources.list &>/dev/null
	apt-get update &>/dev/null
	apt-get -y upgrade &>/dev/null
	
fi
echo $GREEN"                             ====== SUCCESS ======"
sleep 2
echo ""

echo $RED"                      ====== Installing Cairo-Dock ======"
# Install Cairo-Dock
apt-get -y install cairo-dock &>/dev/null
echo $GREEN"                             ====== SUCCESS ======"
sleep 2
echo ""


# Install Java 64 bit
echo $RED"                      ====== Installing Java 64Bit ======"
cd /root &>/dev/null
wget -N http://download.oracle.com/otn-pub/java/jdk/7u17-b02/jdk-7u17-linux-x64.tar.gz &>/dev/null
tar -xzvf jdk-7u17-linux-x64.tar.gz &>/dev/null
if [ -d jdk1.7.0_17  ]; then
	mv jdk1.7.0_17 /opt &>/dev/null
	cd /opt/jdk1.7.0_17 &>/dev/null

	update-alternatives --install /usr/bin/java java /opt/jdk1.7.0_17/bin/java 1 &>/dev/null
	update-alternatives --install /usr/bin/javac javac /opt/jdk1.7.0_17/bin/javac 1 &>/dev/null
	update-alternatives --install /usr/lib/mozilla/plugins/libjavaplugin.so mozilla-javaplugin.so /opt/jdk1.7.0_17/jre/lib/amd64/libnpjp2.so 1 &>/dev/null
	update-alternatives --set java /opt/jdk1.7.0_17/bin/java &>/dev/null
	update-alternatives --set javac /opt/jdk1.7.0_17/bin/javac &>/dev/null
	update-alternatives --set mozilla-javaplugin.so /opt/jdk1.7.0_17/jre/lib/amd64/libnpjp2.so &>/dev/null
else
	echo " ------ ERROR Installing Java 64 -jdk 1.7 "
fi
echo $GREEN"                             ====== SUCCESS ======"
sleep 2
cd /root/ &>/dev/null
echo ""

echo $RED"                   ====== Installing Angry IP Scanner ======"
# Install angry-IP-scanner
cd /root/ &>/dev/null
if [ $(uname -m) == "x86_64" ] ; then
	#64 bit system
	wget -N http://sourceforge.net/projects/ipscan/files/ipscan3-binary/3.2/ipscan_3.2_amd64.deb &>/dev/null
	dpkg -i ipscan_3.2_amd64.deb &>/dev/null
else
	wget -N http://sourceforge.net/projects/ipscan/files/ipscan3-binary/3.2/ipscan_3.2_i386.deb &>/dev/null
	dpkg -i ipscan_3.2_i386.deb &>/dev/null
fi
echo $GREEN"                             ====== SUCCESS ======"
sleep 2
echo ""

echo $RED"                         ====== Installing Xchat ======"
# Install xchat
apt-get -y install xchat &>/dev/null
echo $GREEN"                             ====== SUCCESS ======"
sleep 2
echo ""

echo $RED"                      ====== Installing Terminator ======"
# Install Terminator
apt-get -y install terminator &>/dev/null
echo $GREEN"                             ====== SUCCESS ======"
sleep 2
echo ""

echo $RED"                        ====== Installing WPSscan ======"
#Install WPSscan
cd /root &>/dev/null
apt-get -y install libcurl4-gnutls-dev libopenssl-ruby libxml2 libxml2-dev libxslt1-dev ruby-dev &>/dev/null
git clone https://github.com/wpscanteam/wpscan.git &>/dev/null
cd /root/wpscan &>/dev/null
gem install bundle &>/dev/null && bundle install &>/dev/null
echo $GREEN"                             ====== SUCCESS ======"
sleep 2
echo ""

echo $RED"                          ====== Adding Conky ======"
apt-get install -y lm-sensors conky &>/dev/null
cp /etc/conky/conky.conf /etc/conky/conky.conf.orig &>/dev/null
# Get the THS Conky Script, but don't install.
wget -N http://pastebin.com/download.php?i=g1qGiVyP -o /etc/conky/ths-conky.conf &>/dev/null
# Need to figure out if i8 is supported
# or install a plainer version.
echo $GREEN"                             ====== SUCCESS ======"
sleep 2
clear

echo $STAND"                            ====== Cleaning up ======"
sleep 2
#Clean up apt-get
apt-get -y autoremove
apt-get clean
