#!/bin/sh

#!/bin/bash

clear
echo "================================================="
echo " This script is to install the 32 bit libraries"
echo " that are required for the Cisco VPN Client"
echo " on Kali linux. Please DO NOT run this script if"
echo " you are NOT running 64 bit Kali! This may or may"
echo " not work on other versions of linux but is only"
echo " tested and confirmed working on Kali."
echo ""
echo "================================================"
echo ""
echo " This is licensed under GPLv3."
echo " If there are any questions regarding the license"
echo " please go to http://www.gnu.org/licenses/gpl.html"
echo ""
echo " Currently maintained by James Luther (CaptainHooligan)"
echo ""
echo "================================================="
echo "Press [ENTER] to continue..."
read
echo ""
clear
echo ""
echo -e "========================================================="
echo -e "Kali 32 bit Library Installer"
echo -e "========================================================="
echo ""
WHOAMI=`id | sed -e 's/(.*//'`
if [ "$WHOAMI" != "uid=0" ] ; then
        echo "Sorry, you need super user access to run this script."
        exit 1
fi
dpkg --add-architecture i386
apt-get update && apt-get -y install ia32-libs

#!/bin/bash

clear
echo "================================================="
echo " This script is to install the Cisco VPN Client"
echo " on Kali linux. This may or may not"
echo " work on other versions of linux but is only"
echo " tested and confirmed working on Kali."
echo ""
echo "================================================"
echo ""
echo " This is licensed under GPLv3."
echo " If there are any questions regarding the license"
echo " please go to http://www.gnu.org/licenses/gpl.html"
echo ""
echo " Currently maintained by James Luther (CaptainHooligan)"
echo ""
echo "================================================="
echo "Press [ENTER] to continue..."
read
echo ""
clear
echo ""
echo -e "========================================================="
echo -e "Kali Cisco VPN Installer"
echo -e "========================================================="
echo ""
WHOAMI=`id | sed -e 's/(.*//'`
if [ "$WHOAMI" != "uid=0" ] ; then
        echo "Sorry, you need super user access to run this script."
        exit 1
fi
echo ""
echo ""
echo -e "Setting up folders..."
echo ""
installdir=`pwd`
echo ""
echo -e "Extracting Files..."
echo ""
tar xf Cisco-VPN.tar.gz
cd VPN
tar xf vpnclient-linux-x86_64-4.8.02.0030-k9.tar.gz
echo ""
echo -e "Ensuring Kernel Sources are prepared..."
echo ""
sudo apt-get install linux-headers-$(uname -r)
cd /usr/src/linux-headers-$(uname -r)
cp -rf include/generated/* include/linux
cd $INSTALLDIR/VPN/vpnclient
echo ""
cd $installdir/VPN/vpnclient
echo -e "Applying Patches..."
echo ""
patch < ../ciscovpn-kali.patch
echo ""
echo -e "Compiling and installing Cisco VPN. Please be patient and answer all on screen questions."
echo ""
./vpn_install
