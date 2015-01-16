#!/bin/sh
# http://www.axozie.org/2014/09/install-amd-ati-proprietary-fglrx_8.html

# Backup
mv /etc/apt/sources.list /etc/apt/sources.list.bak

# New sources file
cat <<EOF > /etc/apt/sources.list
#Official Repo Kali linux
deb http://http.kali.org/ /wheezy main contrib non-free
deb-src http://repo.kali.org/kali kali main non-free contrib
deb http://repo.kali.org/kali kali main/debian-installer
deb http://repo.kali.org/kali kali main contrib non-free
deb-src http://repo.kali.org/kali kali main contrib non-free
deb http://security.kali.org/kali-security kali/updates main contrib non-free
deb-src http://security.kali.org/kali-security kali/updates main contrib non-free
EOF

apt-get update
apt-get install firmware-linux-nonfree 
apt-get install amd-opencl-icd 
apt-get install linux-headers-$(uname -r)

apt-get install fglrx-atieventsd fglrx-driver fglrx-control fglrx-modules-dkms -y

aticonfig --initial -f