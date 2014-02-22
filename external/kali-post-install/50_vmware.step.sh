#!/bin/bash

dmi=`dmidecode | awk '/VMware Virtual Platform/ {print $3}'`
if [[ "$dmi" !=  *VMware* ]]; then exit 3; fi

. ask.sh

ask "It seems you're running kali as vmware guest, do you want to install vmware-tools?" Y || exit 3

apt-get install -y xserver-xorg-input-vmmouse
 
echo cups enabled >> /usr/bin/update-rc.d
echo vmware-tools enabled >> /usr/bin/update-rc.d
install gcc make linux-headers-$(uname -r)

ln -s /usr/src/linux-headers-$(uname -r)/include/generated/uapi/linux/version.h /usr/src/linux-headers-$	(uname -r)/include/linux/

read -p "please choose 'install vmware tools' on your host and hit any key when done"
echo 

mkdir /mnt/vmware
mount /dev/cdrom /mnt/vmware
tar zxpf /mnt/vmware/VMwareTools-*.tar.gz -C /tmp/
/tmp/vmware-tools-distrib/vmware-install.pl default

rm -rf /mnt/vmware
rm -rf /tmp/vmware-*
