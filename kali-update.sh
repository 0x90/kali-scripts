#!/bin/sh
#This function shows which switches are needed to run the script.
usage(){
	echo "Use one or more of the following switches"
	echo " -p Upgrade packages"
	echo " -e Install select extra packages"
	echo " -s Install select tools from source"
	echo " -a All, same as -pes"
	echo " -h see this message"
}

#This option updates the packages installed and Metasploit.
package(){
	echo -e "\e[1;34m[*] Updating the entire system.\e[0m"
  apt-get update && apt-get upgrade -y
  echo -e "\e[1;34m[*]Making sure MSF startups on boot.\e[0m"
  ls /etc/rc* | grep "S..metasploit"
  if [ $? -eq 1 ]; then
    update-rc.d postgresql enable && update-rc.d metasploit enable
  fi
  echo -e "\e[1;34m[*]Updating MSF.\e[0m"
  /opt/metasploit/apps/pro/msf3/msfupdate
  cd /opt/metasploit/apps/pro/msf3/
  bundle install
}

#This installs extra packages I find most useful to add to a fresh Kali install.
extra(){
  echo -e "\e[1;34m[*]Adding some needed and nice packages.\e[0m"
  apt-get install -y cifs-utils autoconf terminator libssl-dev hostapd ipcalc isc-dhcp-server chromium cmake cmake-data emacsen-common libltdl-dev libpcap0.8-dev libtool libxmlrpc-core-c3 arp-scan filezilla gedit recon-ng xdotool

}

#This section installs software from source.
#Fuzzdb is downloaded from svn
#Nmap is build in the /opt/nmap-svn dir but it is not installed over the package, so you have to call it manually
#Aircrack-ng is downloaded and compiled and it is installed over the package, I've found airobase-ng to be buggy otherwise.

source(){
  echo -e "\e[1;34m[*]Making sure packages required to build things are there.\e[0m"
  apt-get -y install autoconf libssl-dev
  echo -e "\e[1;34m[*]Installing SVN version of fuzzdb in /usr/share/fuzzdb and keeping it updated.\e[0m"
  if [ -d /usr/share/fuzzdb ]; then
    cd /usr/share/fuzzdb
    svn up
  else
    echo -e "\e[1;34m[*]Fuzzdb not found, installing at /usr/share/fuzzdb.\e[0m"
    cd /usr/share
    svn co http://fuzzdb.googlecode.com/svn/trunk fuzzdb
  fi
  echo -e "\e[1;34m[*]Adding nmap-svn to /opt/nmap-svn.\e[0m"
  svn co --username guest --password "" https://svn.nmap.org/nmap /opt/nmap-svn
  cd /opt/nmap-svn
  ./configure && make
  /opt/nmap-svn/nmap -V
  echo "Installed in /opt/nmap-svn"
  echo -e "\e[1;34m[*]Updating aircrack-ng from SVN.\e[0m"
  if [ -d /opt/aircrack-ng-svn ]; then
    cd /opt/aircrack-ng-svn
    svn up
  else
    svn co http://svn.aircrack-ng.org/trunk/ /opt/aircrack-ng-svn
    cd /opt/aircrack-ng-svn
  fi
  make && make install
  airodump-ng-oui-update
  #Checking for free-radius and it not found installing it with the wpe patch.  This code is totally stollen from the easy-creds install file.  :-D
  if [ ! -e /usr/bin/radiusd ] && [ ! -e /usr/sbin/radiusd ] && [ ! -e /usr/local/sbin/radiusd ] && [ ! -e /usr/local/bin/radiusd ]; then
  echo -e "\e[1;34m[-] free-radius is not installed, will attempt to install...\e[0m"
  sleep 2
  mkdir /tmp/freeradius
  echo -e "\n\e[1;34m[*] Downloading freeradius server 2.1.11 and the wpe patch...\e[0m"
  wget ftp://ftp.freeradius.org/pub/radius/old/freeradius-server-2.1.11.tar.bz2 -O /tmp/freeradius/freeradius-server-2.1.11.tar.bz2
  wget http://www.opensecurityresearch.com/files/freeradius-wpe-2.1.11.patch -O /tmp/freeradius/freeradius-wpe-2.1.11.patch
  cd /tmp/freeradius
  tar -jxvf freeradius-server-2.1.11.tar.bz2
  mv freeradius-wpe-2.1.11.patch /tmp/ec-install/freeradius-server-2.1.11/freeradius-wpe-2.1.11.patch
  cd freeradius-server-2.1.11
  patch -p1 < freeradius-wpe-2.1.11.patch
  echo -e "\n\e[1;34m[*] Installing the patched freeradius server...\e[0m"
  sleep 3
  ./configure && make && make install
  cd /usr/local/etc/raddb/certs/
  ./bootstrap
  rm -r /tmp/freeradius
  echo -e "\n\e[1;34m[+] The patched freeradius server has been installed\e[0m"
  sleep 2
else
  echo -e "\e[1;34m[+] I found free-radius installed on your system\e[0m"
  sleep 2
fi
#Installing easy-creds.  The needed packages should be taken care of in the extra packages section.
if [ -d /opt/easy-creds ]; then
  echo "\e[1;34m[*]Easy easy-creds install already found.\e[0m"
else
git clone git://github.com/brav0hax/easy-creds.git /opt/easy-creds
ln -s /opt/easy-creds/easy-creds.sh /usr/bin/easy-creds
fi
updatedb
  #Saying what happened:
  echo -e "\e[1;34m[*]Installed or updated Fuzzdb to /usr/share/fuzzdb.\e[0m"
  echo -e "\e[1;34m[*]Installed or updated nmap-svn to /opt/nmap-svn.\e[0m"
  echo -e "\e[1;34m[*]Downloaded svn version of aircrack-ng to /opt/aircrack-ng-svn and overwrote package with it.\e[0m"
  echo -e "\e[1;34m[*]If free-radius was not found, it was installed with the wpe patch.\e[0m"
  echo -e "\e[1;34m[*]If easy-creds was not found it was installed.\e[0m"
  sleep 5
}

#This displays the usage info if you didn't put in a switch.
(($# )) || usage

#This is the main logic calling the proper functions based on the switches used.
while getopts "pesah" flag
do
  if [ "$flag" = "h" ]; then
  	usage
  elif [ "$flag" = "p" ]; then
  	package
  elif [ "$flag" = "e" ]; then
  	extra
  elif [ "$flag" = "s" ]; then
  	source
  elif [ "$flag" = "a" ]; then
  	package
  	extra
  	source
  else
  	usage
  fi
done
