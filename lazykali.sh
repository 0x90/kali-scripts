#!/bin/bash


##############################################
#
# LazyKali by Reaperz73
# Just made this for when I feel lazy
# Installs quite a few extras to a Fresh Kali:)
# questions comments or request email me @:
# reaperz73revived@gmail.com
#
##############################################
clear
version="20130524"
#some variables
DEFAULT_ROUTE=$(ip route show default | awk '/default/ {print $3}')
IFACE=$(ip route show | awk '(NR == 2) {print $3}')
JAVA_VERSION=`java -version 2>&1 |awk 'NR==1{ gsub(/"/,""); print $3 }'`
MYIP=$(ip route show | awk '(NR == 2) {print $9}')

if [ $UID -ne 0 ]; then
    echo -e "\033[31This program must be run as root.This will probably fail.\033[m"
    sleep 3
    fi

###### Install script if not installed
if [ ! -e "/usr/bin/lazykali" ];then
  echo "Script is not installed. Do you want to install it ? (Y/N)"
	read install
	if [[ $install = Y || $install = y ]] ; then
		cp -v $0 /usr/bin/lazykali
		chmod +x /usr/bin/lazykali
		#rm $0
		echo "Script should now be installed. Launching it !"
		sleep 3
		lazykali
		exit 1
	else
		echo -e "\e[32m[-] Ok,maybe later !\e[0m"
	fi
else
	echo "Script is installed"
	sleep 1
fi
### End of install process

### Check for updates !
if [[ "$silent" = "1" ]];then
	echo "Not checking for a new version : silent mode."
else
	changelog=$(curl --silent -q http://yourgeekonthego.com/scripts/lazykali/changelog)
	last_version=$(curl --silent -q http://yourgeekonthego.com/scripts/lazykali/version) #store last version number to variable
	if [[ $last_version > $version ]];then # Comparing to current version
		echo -e "You are running version \033[31m$version\033[m, do you want to update to \033[32m$last_version\033[m? (Y/N)
Last changes are :
$changelog"
		read update
		if [[ $update = Y || $update = y ]];then
			echo "[+] Updating script..."
			wget -q http://yourgeekonthego.com/scripts/lazykali/lazykali.sh -O $0
			chmod +x $0
			echo "[-] Script updated !"
			if [[ $0 != '/usr/bin/yamas' && $ask_for_install = 'y' ]];then
				echo -e "Do you want to install it so that you can launch it with \"lazykali\" ?"
				read install
				if [[ $install = Y || $install = y ]];then #do not proceed to install if using installed version : updating it already "installed" it over.
					cp $0 /usr/bin/lazykali
					chmod +x /usr/bin/lazykali
					echo "Script should now be installed, launching lazykali !"
					sleep 3
					lazykali
					exit 1
				else
					echo "Ok, continuing with updated version..."
					sleep 3
					$0
					exit 1
				fi
			fi
		
		sleep 2
		$0
		exit 1
		else
			echo "Ok, continuing with current version..."
		fi
	else
		echo "No update available"
	fi
fi
### End of update process

#### pause function
function pause(){
   read -sn 1 -p "Press any key to continue..."
}

#### credits
function credits {
clear
echo -e "
\033[31m#######################################################\033[m
                       Credits To
\033[31m#######################################################\033[m"
echo -e "\033[36m
Special thanks to:
Offensive Security for the awesome OS
http://www.offensive-security.com/
http://www.kali.org/

ComaX for Yamas
http://comax.fr/yamas.php

Brav0hax for Easy-Creds
https://github.com/brav0hax/easy-creds

VulpiArgenti for PwnStar
http://code.google.com/p/pwn-star/

skysploit for Simple-Ducky
http://code.google.com/p/simple-ducky-payload-generator/

0sm0s1z for Subterfuge
http://code.google.com/p/subterfuge/

and anyone else I may have missed.

\033[m"
}

#### Screwup function
function screwup {
	echo "You Screwed up somewhere, try again."
	pause 
	clear
}


######## Update Kali
function updatekali {
clear
echo -e "
\033[31m#######################################################\033[m
                Let's Update Kali
\033[31m#######################################################\033[m"
select menusel in "Update Kali" "Update and Clean Kali" "Back to Main"; do
case $menusel in
	"Update Kali")
		clear
		echo -e "\033[32mUpdating Kali\033[m"
		#apt-get update && apt-get -y dist-upgrade
		apt-get update && apt-get -y upgrade 
		echo -e "\033[32mDone updating kali\033[m"
		pause
		clear ;;
	
	"Update and Clean Kali")
		clear
		echo -e "\033[32mUpdating and Cleaning Kali\033[m"
		apt-get update && apt-get -y dist-upgrade && apt-get autoremove -y && apt-get -y autoclean
		echo -e "\033[32mDone updating and cleaning kali\033[m" ;;
		
	"Back to Main")
		clear
		mainmenu ;;
		
	*)
		screwup
		updatekali ;;

esac

break

done
}

##### Metasploit Services
function metasploitservices {
clear
echo -e "
\033[31m#######################################################\033[m
                Metasploit Services
\033[31m#######################################################\033[m"
select menusel in "Start Metasploit Services" "Stop Metasploit Services" "Restart Metasploit Services" "Autostart Metasploit Services" "Back to Main"; do
case $menusel in
	"Start Metasploit Services")
		echo -e "\033[32mStarting Metasploit Services..\033[m"
		service postgresql start && service metasploit start
		echo -e "\033[32mNow Open a new Terminal and launch msfconsole\033[m"
		pause ;;
	
	"Stop Metasploit Services")
		echo -e "\033[32mStoping Metasploit Services..\033[m"
		service postgresql stop && service metasploit stop
		pause ;;
		
	"Restart Metasploit Services")
		echo -e "\033[32mRestarting Metasploit Services..\033[m"
		service postgresql restart && service metasploit restart
		pause ;;
		
	"Autostart Metasploit Services")
		echo -e "\033[32mSetting Metasploit Services to start on boot..\033[m"
		update-rc.d postgresql enable && update-rc.d metasploit enable
		pause ;;

	"Back to Main")
		clear
		mainmenu ;;
		
	*)
		screwup
		metasploitservices ;;		
		
esac

break

done
}

######## Open Vas Services
function OpenVas {
clear
echo -e "
\033[31m#######################################################\033[m
                  OpenVas Services
\033[31m#######################################################\033[m"
select menusel in "Start OpenVas Services" "Stop OpenVas Services" "Rollback V5" "Back to Main"; do
case $menusel in
	"Start OpenVas Services")
		openvasstart
		pause 
		OpenVas;;
	
	"Stop OpenVas Services")
		openvasstop
		pause
		OpenVas ;;
		
	"Rollback V5")
		rollbackopenvas
		pause
		OpenVas ;;

	"Back to Main")
		clear
		mainmenu ;;
		
	*)
		screwup
		OpenVas ;;
	
		
esac

break

done
}

######## Update Exploitdb
function exploitdb {
clear
echo -e "
\033[31m#######################################################\033[m
                          Exploit-DB
\033[31m#######################################################\033[m"
select menusel in "Update Exploitdb" "Searchsploit" "Back to Main"; do
case $menusel in
	"Update Exploitdb")
		updateexploitdb
		pause 
		exploitdb;;
	
	"Searchsploit")
		searchsploit
		pause
		exploitdb ;;

	"Back to Main")
		clear
		mainmenu ;;
		
	*)
		screwup
		OpenVas ;;
	
		
esac

break

done
}


######## Sniffing and spoofing menu
function sniffspoof {
clear
echo -e "
\033[31m#######################################################\033[m
                Sniffing/Spoofing/MITM
\033[31m#######################################################\033[m"
select menusel in "Yamas" "EasyCreds" "PwnStar" "Subterfuge" "Ghost-Phisher" "Hamster&Ferret" "Back to Main"; do
case $menusel in
	"Yamas")
		installyamas
		pause
		sniffspoof ;;
		
	"EasyCreds")
		easycreds
		pause
		sniffspoof ;;
	
	"PwnStar")
		pwnstar
		pause
		sniffspoof ;;
		
	"Subterfuge")
		subterfuge
		pause
		sniffspoof ;;
		
	"Ghost-Phisher")
		ghostphisher
		pause
		sniffspoof ;;
		
	"Hamster&Ferret")
		hamfer
		pause
		sniffspoof ;;

	"Back to Main")
		clear
		mainmenu ;;
		
	*)
		screwup
		sniffspoof ;;
	
		
esac

break

done
}

######## Sniffing and spoofing menu
function payloadgen {
clear
echo -e "
\033[31m#######################################################\033[m
                Sniffing/Spoofing/MITM
\033[31m#######################################################\033[m"
select menusel in "Simple-Ducky" "Back to Main"; do
case $menusel in
	"Simple-Ducky")
		simpleducky
		pause
		payloadgen ;;
		
	"Back to Main")
		clear
		mainmenu ;;
		
	*)
		screwup
		sniffspoof ;;
	
		
esac

break

done
}

function bleedingedge {
		#Add bleeding edge repository
		out=`grep  "kali-bleeding-edge" /etc/apt/sources.list` &>/dev/null
		if [[ "$out" !=  *kali-bleeding-edge* ]]; then &>/dev/null
		echo "Bleeding Edge Repo is not installed. Do you want to install it ? (Y/N)"
		read install
			if [[ $install = Y || $install = y ]] ; then
				echo -e "\033[31m====== Adding Bleeding Edge repo and updating ======\033[m"
				echo "" >> /etc/apt/sources.list
				echo '# Bleeding Edge ' >> /etc/apt/sources.list
				echo 'deb http://repo.kali.org/kali kali-bleeding-edge main' >> /etc/apt/sources.list
				apt-get update
				apt-get -y upgrade
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
		else
			echo -e "\e[32m[-] Bleeding Edge Repo already there!\e[0m"
			sleep 1
		fi
}

function installangryip {
if [ ! -e "/usr/bin/ipscan" ];then
			echo "AngryIp Scanner is not installed. Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then	
				echo -e "\033[31m====== Installing Angry IP Scanner ======\033[m"
				# Install angry-IP-scanner
				cd /root/ &>/dev/null
				if [ $(uname -m) == "x86_64" ] ; then
					#64 bit system
					wget -N http://sourceforge.net/projects/ipscan/files/ipscan3-binary/3.2/ipscan_3.2_amd64.deb &>/dev/null
					dpkg -i ipscan_3.2_amd64.deb &>/dev/null
				else
					#32 bit system
					wget -N http://sourceforge.net/projects/ipscan/files/ipscan3-binary/3.2/ipscan_3.2_i386.deb &>/dev/null
					dpkg -i ipscan_3.2_i386.deb &>/dev/null
				fi
				pause
				exit 1
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
		else
			echo -e "\e[32m[-] AngryIP Scanner is installed!\e[0m"
		fi
}

function installterminator {
	echo "This will install Terminator. Do you want to install it ? (Y/N)"
	read install
	if [[ $install = Y || $install = y ]] ; then
		apt-get -y install terminator
		echo -e "\e[32m[-] Done Installing Terminator!\e[0m" 
	else
		echo -e "\e[32m[-] Ok,maybe later !\e[0m"
	fi
}

function installxchat {
	echo "This will install Xchat. Do you want to install it ? (Y/N)"
	read install
	if [[ $install = Y || $install = y ]] ; then
		apt-get -y install xchat 
		echo -e "\e[32m[-] Done Installing XChat!\e[0m"
	else
		echo -e "\e[32m[-] Ok,maybe later !\e[0m"
	fi
}

function installnautilusopenterm {
	echo "This will install Nautilus Open Terminal. Do you want to install it ? (Y/N)"
	read install
	if [[ $install = Y || $install = y ]] ; then
		apt-get -y install nautilus-open-terminal
		gsettings set org.gnome.desktop.default-applications.terminal exec /usr/bin/terminator
		gsettings set org.gnome.desktop.default-applications.terminal exec-arg "-x"
		echo -e "\e[32m[-] Done Installing Nautilus Open Terminal!\e[0m"
	else
		echo -e "\e[32m[-] Ok,maybe later !\e[0m"
	fi
	
}

function installunicornscan {
	if [ ! -f /usr/local/bin/unicornscan ]; then
		echo "This will install Unicornscan. Do you want to install it ? (Y/N)"
		read install
			if [[ $install = Y || $install = y ]] ; then
				echo -e "\033[31m====== Installing Flex ======\033[m"
				apt-get install flex &>/dev/null
				echo -e "\033[32m====== Done Installing Flex ======\033[m"
				echo -e "\033[31m====== Installing Unicornscan ======\033[m"
				cd /root/ &>/dev/null
				wget -N http://unicornscan.org/releases/unicornscan-0.4.7-2.tar.bz2 
				bzip2 -cd unicornscan-0.4.7-2.tar.bz2 | tar xf - 
				cd unicornscan-0.4.7/ 
				./configure CFLAGS=-D_GNU_SOURCE && make && make install
				cd /root/ &>/dev/null
				rm -rf unicornscan-0.4.7*
				echo -e "\033[32m====== All Done ======\033[m"
				echo "Launch a new terminal and enter unicornscan to run."
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
		else
			echo -e "\e[32m[-] Done Installing Unicornscan!\e[0m"
			echo "Launch a new terminal and enter unicornscan to run."
			
		fi	
}

function installyamas {
	if [ ! -f /usr/bin/yamas ]; then
		echo "Yamas is not installed. Do you want to install it ? (Y/N)"
		read install
		if [[ $install = Y || $install = y ]] ; then
			cd /tmp
			wget http://comax.fr/yamas/bt5/yamas.sh
			cp yamas.sh /usr/bin/yamas
			chmod +x /usr/bin/yamas
			rm yamas.sh
			cd
			echo "Script should now be installed. Launching it !"
			sleep 3
			gnome-terminal -t "Yamas" -x bash yamas 2>/dev/null & sleep 2
			exit 1
		else
			echo -e "\e[32m[-] Ok,maybe later !\e[0m"
		fi
	else
		echo "Script is installed"
		gnome-terminal -t "Yamas" -x bash yamas 2>/dev/null & sleep 2
		sleep 1
	fi		
}


######## install hackpack
function installhackpack {
	echo "This will install Hackpack. Do you want to install it ? (Y/N)"
	read install
	if [[ $install = Y || $install = y ]] ; then
		cd /tmp
		wget http://lazykali.googlecode.com/files/hackpack.tar.gz
		tar zxvf hackpack.tar.gz
		cd hackpack
		echo -e "\033[31m====== Installing ======\033[m"
		./install.sh
		echo -e "\e[32m[-] Done !\e[0m"
		cd ../
		echo -e "\033[31m====== Cleaning up ======\033[m"
		rm hackpack.tar.gz
		rm -rf hackpack
		echo -e "\e[32m[-] Done !\e[0m"
	else
		echo -e "\e[32m[-] Ok,maybe later !\e[0m"
	fi
	
}



function easycreds {
	if [ ! -f /usr/bin/easy-creds ]; then
		echo "This will install Easy-Creds. Do you want to install it ? (Y/N)"
		read install
			if [[ $install = Y || $install = y ]] ; then
				echo -e "\033[31m====== Installing Depends ======\033[m"
				apt-get -y install screen hostapd dsniff dhcp3-server ipcalc aircrack-ng
				echo -e "\033[32m====== Done Installing Depends ======\033[m"
				echo -e "\033[31m====== Installing Easy-Creds ======\033[m"
				git clone git://github.com/brav0hax/easy-creds.git /opt/easy-creds
				ln -s /opt/easy-creds/easy-creds.sh  /usr/bin/easy-creds
				cd /root/ &>/dev/null
				echo -e "\033[32m===== All Done ======\033[m"
				echo "Launching easy-creds in new window !"
				gnome-terminal -t "Easy-Creds" -e easy-creds 2>/dev/null & sleep 2				
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
		else
			echo "Easy-Creds is installed."
			echo "Launching easy-creds in new window !"
			gnome-terminal -t "Easy-Creds" -e easy-creds 2>/dev/null & sleep 2	
		fi	
}

######### PwnStar
function pwnstar {
		if [ ! -e "/opt/PwnSTAR_0.9/PwnSTAR_0.9" ];then
			echo "PwnStar is not installed. Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then
				mkdir /opt/PwnSTAR_0.9
				cd /opt/PwnSTAR_0.9
				wget http://pwn-star.googlecode.com/files/PwnSTAR_0.9.tgz
				tar -zxvf PwnSTAR_0.9.tgz 
				mv hotspot_3 /var/www/ && mv portal_hotspot /var/www/ && mv portal_pdf /var/www/ && mv portal_simple /var/www/
				#rm $0
				echo "PwnStar should now be installed. Launching it !"
				sleep 3
				gnome-terminal -t "PwnStar" -e /opt/PwnSTAR_0.9/PwnSTAR_0.9 2>/dev/null & sleep 2
				pause
				sniffspoof
				exit 1
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
		else
			echo "PwnStar is installed, Launching it now!"
			sleep 1
			gnome-terminal -t "PwnStar" -e /opt/PwnSTAR_0.9/PwnSTAR_0.9 2>/dev/null & sleep 2
		fi 
}

### Hunting with rodents hamster and ferret
function hamfer {
		if [ ! -e "/usr/share/hamster-sidejack/ferret" ];then
			echo -e "\033[31m[+] Creating link /usr/share/hamster-sidejack/ferret\033[m"
			echo "we need this to avoid file not found error"
			ln -s /usr/bin/ferret /usr/share/hamster-sidejack/ferret
			hamfer			
		else
			echo -e "\033[31m[+] Starting Sidejacking with Hamster & Ferret.\033[m"
			echo "1" > /proc/sys/net/ipv4/ip_forward
			iptables -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port 1000
			sslstrip -f -a -k -l 1000 -w /root/out.txt &
			sleep 4
			xterm -T "arpspoof" -e arpspoof -i $IFACE $DEFAULT_ROUTE &
			sleep 2
			#xterm -e /usr/share/hamster-sidejack/ferret -i $IFACE 2>/dev/null & sleep 2
			cd /usr/share/hamster-sidejack
			xterm -e ./hamster 2>/dev/null & sleep 2 
			echo -e "\n\033[31m[+] Attack is running\033[m.\nSet browser proxy to 127.0.0.1:1234\nIn Browser go to http://hamster\nPress (q) to stop"
			cd
			while read -n1 char
			do
				case $char in
				q)
				break
				;;
			
				* )
					echo -ne "\nInvalid character '$char' entered. Press (q) to quit."
				esac
			done
			echo -e "\033[31m\n[+] Killing processes and resetting iptable.\033[m"
			killall sslstrip
			killall arpspoof
			killall ferret
			killall hamster
			echo "0" > /proc/sys/net/ipv4/ip_forward
			iptables --flush
			iptables --table nat --flush
			iptables --delete-chain
			iptables --table nat --delete-chain
			echo -e "\033[32m[-] Clean up successful !\033[m"
	
		fi	

}

#####simple-ducky
function installsimpleducky {
	if [ ! -e "/usr/bin/simple-ducky" ];then
			echo "Simple-Ducky is not installed. Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then
				wget https://simple-ducky-payload-generator.googlecode.com/files/installer_v1.1.0_debian.sh
				chmod +x installer_v1.1.0_debian.sh
				./installer_v1.1.0_debian.sh
				rm installer_v1.1.0_debian.sh
				echo -e "\e[1;34mDone! Be sure to run Option's 5 and 6 prior to generating any payloads.\e[0m"
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
		else
			echo -e "\e[32m[-] Simple-Ducky is installed!\e[0m"
			echo "Launch a new terminal and enter simple-ducky to run."			
		fi	
}

#################################################################################
# JAVA JDK Update
#################################################################################
function installjava {
	echo -e "\e[1;31mThis option will update your JDK version to jdk1.7.0\e[0m"
	echo -e "\e[1;31mUse this only if java not installed or your version is older than this one!\e[0m"
	echo -e "\e[1;31mYour current Version is : $JAVA_VERSION\e[0m"
	echo "Do you want to install it ? (Y/N)"
	read install
	if [[ $install = Y || $install = y ]] ; then
			read -p "Are you using a 32bit or 64bit operating system [ENTER: 32 or 64]? " operatingsys
			if [ "$operatingsys" == "32" ]; then 
				echo -e "\e[1;31m[+] Downloading and Updating to jdk1.7.0\e[0m"
				echo -e ""
				wget --no-cookies --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com" "http://download.oracle.com/otn-pub/java/jdk/7/jdk-7-linux-i586.tar.gz"
				tar zxvf jdk-7-linux-i586.tar.gz
				mv jdk1.7.0 /usr/lib/jvm
				update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk1.7.0/jre/bin/java 2
				echo -e "\e[1;34mWhen prompted, select option 2\e[0m"
				sleep 2
				echo -e ""
				update-alternatives --config java
				rm jdk-7-linux-i586.tar.gz
				echo -e ""
				echo -e "\e[1;34mYour new JDk version is...\e[0m"
				echo ""
				java -version
				sleep 3
				echo ""
			else
				echo -e "\e[1;31m[+] Downloading and Updating to jdk1.7.0\e[0m"
				echo -e ""
				wget --no-cookies --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com" "http://download.oracle.com/otn-pub/java/jdk/7u17-b02/jdk-7u17-linux-x64.tar.gz"
				tar zxvf jdk-7u17-linux-x64.tar.gz
				mv jdk1.7.0_17/ /usr/lib/jvm
				update-alternatives --install /usr/bin/java java /usr/lib/jvm/jdk1.7.0_17/jre/bin/java 2
				echo -e "\e[1;34mWhen prompted, select option 2\e[0m"
				sleep 2
				echo -e ""
				update-alternatives --config java
				rm jdk-7u17-linux-x64.tar.gz
				echo -e ""
				echo -e "\e[1;34mYour new JDk version is...\e[0m"
				echo ""
				java -version
				sleep 3
				echo ""
			fi
		else
			echo -e "\e[32m[-] Ok,maybe later !\e[0m"
		fi

}


######## update ettercap
function installettercap {
	etterversion=`ettercap -version |awk '(NR==2) { print $2 }'`
	echo -e "\e[1;31mThis option will update your Ettercap version to ettercap 0.7.6\e[0m"
	echo -e "\e[1;31mThis may break the ettercap repo. Will have to see when ettercap is upgraded in the repos\e[0m"
	echo -e "\e[1;31mYour current Version is : $etterversion\e[0m"
	echo "Do you want to continue with the install? (Y/N)"
	read install
	if [[ $install = Y || $install = y ]] ; then
			echo -e "\e[31m[+] Installing depends.\e[0m"
			apt-get install debhelper cmake bison flex libgtk2.0-dev libltdl3-dev libncurses-dev libncurses5-dev libnet1-dev libpcap-dev libpcre3-dev libssl-dev ghostscript python-gtk2-dev libpcap0.8-dev
			echo -e "\e[32m[-] Done Installing Depends!\e[0m"
			cd /tmp
			echo -e "\e[31m[+] Downloading Ettercap.\e[0m"
			git clone https://github.com/Ettercap/ettercap.git
			echo -e "\e[31m[+] Building Ettercap.\e[0m"
			cd ettercap
			mkdir build
			cd build
			cmake ../
			make
			echo -e "\e[32m[-] Done Building Ettercap!\e[0m"
			echo -e "\e[31m[+] Installing Ettercap.\e[0m"
			make install
			echo -e "\e[32m[-] Done Installing Ettercap!\e[0m"
			echo -e "\e[31m[+] Deleting temp install files.\e[0m"
			cd ../../
			rm -rf ettercap/
			echo -e "\e[32m[-] Done deleting install files!\e[0m"
			echo -e "\e[1;31mYour current Version or Ettercap is : $etterversion\e[0m"
		else
			echo -e "\e[32m[-] Ok,maybe later !\e[0m"
		fi

}

#################################################################################
# Install Google Chrome
#################################################################################
function installgooglechrome {
	echo -e "\e[1;31mThis option will install Google Chrome Latest Version!\e[0m"
	echo "Do you want to install it ? (Y/N)"
	read install
	if [[ $install = Y || $install = y ]] ; then
			read -p "Are you using a 32bit or 64bit operating system [ENTER: 32 or 64]? " operatingsys
			if [ "$operatingsys" == "32" ]; then 
				echo -e "\e[1;31m[+] Downloading google-chrome-stable_current_i386\e[0m"
				wget wget https://dl.google.com/linux/direct/google-chrome-stable_current_i386.deb
				echo -e "\e[32m[-] Done with download!\e[0m"
				echo -e "\e[1;31m[+] Installing google-chrome\e[0m"
				dpkg -i google-chrome-stable_current_i386.deb
				cp /opt/google/chrome/google-chrome.desktop /usr/share/applications/google-chrome.desktop
				echo -e "\e[1;31m[+] Patching to run as root!\e[0m"
				head -n -1 /opt/google/chrome/google-chrome > temp.txt ; mv temp.txt /opt/google/chrome/google-chrome
				echo 'exec -a "$0" "$HERE/chrome"  "$@" --user-data-dir' >> /opt/google/chrome/google-chrome
				chmod +x /opt/google/chrome/google-chrome
				echo -e "\e[32m[-] Done patching!\e[0m"
				rm google-chrome-stable_current_i386.deb
				echo -e "\e[32m[-] Done installing enjoy chrome!\e[0m"
			else
				echo -e "\e[1;31m[+] Downloading google-chrome-stable_current_amd64\e[0m"
				wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
				echo -e "\e[32m[-] Done with download!\e[0m"
				echo -e "\e[1;31m[+] Installing google-chrome\e[0m"
				dpkg -i google-chrome-stable_current_amd64.deb
				cp /opt/google/chrome/google-chrome.desktop /usr/share/applications/google-chrome.desktop
				echo -e "\e[1;31m[+] Patching to run as root!\e[0m"
				head -n -1 /opt/google/chrome/google-chrome > temp.txt ; mv temp.txt /opt/google/chrome/google-chrome
				echo 'exec -a "$0" "$HERE/chrome"  "$@" --user-data-dir' >> /opt/google/chrome/google-chrome
				chmod +x /opt/google/chrome/google-chrome
				echo -e "\e[32m[-] Done patching!\e[0m"
				rm google-chrome-stable_current_amd64.deb
				echo -e "\e[32m[-] Done installing enjoy chrome!\e[0m"
			fi
		else
			echo -e "\e[32m[-] Ok,maybe later !\e[0m"
		fi

}

function simpleducky {
	if [ ! -e "/usr/bin/simple-ducky" ];then
			echo "Simple-Ducky is not installed. Do you want to install it ? (Y/N)"
			read install
			if [[ $install = Y || $install = y ]] ; then
				installsimpleducky
				payloadgen
				exit 1
			else
				echo -e "\e[32m[-] Ok,maybe later !\e[0m"
			fi
		else
			echo -e "\e[31m[+] Launching Simple-Ducky now!\nBe sure to run Option's 5 and 6 prior to generating any payloads.\e[0m"
			sleep 1
			gnome-terminal -t "Simple-Ducky" -e "bash simple-ducky" 2>/dev/null & sleep 2
		fi 
}

#####openvasstart
function openvasstart {
# style variables
execstyle="[\e[01;32mx\e[00m]" # execute msgs style
warnstyle="[\e[01;31m!\e[00m]" # warning msgs stylee
infostyle="[\e[01;34mi\e[00m]" # informational msgs style

#fun little banner
clear
echo -e "\e[01;32m 
####### ######  ####### #     # #     #    #     #####  
#     # #     # #       ##    # #     #   # #   #     # 
#     # #     # #       # #   # #     #  #   #  #       
#     # ######  #####   #  #  # #     # #     #  #####  
#     # #       #       #   # #  #   #  #######       # 
#     # #       #       #    ##   # #   #     # #     # 
####### #       ####### #     #    #    #     #  #####  
                                                        
\e[0m"
echo -e "\e[1;1m   ..----=====*****(( Startup Script ))*******=====----..\e[0m"
echo -e "\e[31m *************************************************************\e[0m"
echo -e "\e[31m *                                                           *\e[0m"
echo -e "\e[31m *              \e[1;37mStarting All OpenVas Services \e[0;31m               *\e[0m"
echo -e "\e[31m *                      By Reaperz73                         *\e[0m"
echo -e "\e[31m *************************************************************\e[0m"

echo
echo -e "\e[31mKilling all Openvas for fresh start.\e[0m"
#kill openvas scanner
echo -e "$execstyle Checking OpenVas Scanner is running..."
ps -ef | grep -v grep | grep openvassd
if [ $? -eq 1 ]
 then
	echo -e "$warnstyle OpenVas Scanner not running!" 
 else
	echo -e "$execstyle Stopping OpenVas Scanner..."
	killall openvassd
fi

#kill openvas administrator
echo -e "$execstyle Checking if OpenVas Administrator is running..."
ps -ef | grep -v grep | grep openvasad
if [ $? -eq 1 ]
 then
	echo -e "$warnstyle OpenVas Administrator not running!" 
 else
	echo -e "$execstyle Stopping OpenVas Administrator..."
	killall openvasad
fi

#kill openvas manager
echo -e "$execstyle Checking if OpenVas Manager is running..."
ps -ef | grep -v grep | grep openvasmd
if [ $? -eq 1 ]
 then
	echo -e "$warnstyle OpenVas Manager not running!" 
 else
	echo -e "$execstyle Stopping OpenVas Manager..."
	killall openvasmd
fi

#kill Greenbone Security Assistant
echo -e "$execstyle Checking if Greenbone Security Assistant is running..."
ps -ef | grep -v grep | grep gsad
if [ $? -eq 1 ]
 then
	echo -e "$warnstyle Greenbone Security Assistant not running!" 
 else
	echo -e "$execstyle Stopping Greenbone Security Assistant..."
	killall gsad
fi

#### all done! now start services
echo
echo -e "\033[31mAll Done!! :\033[m
Now starting OpenVas services..."

echo -e "\033[31mSyncing updates.......\033[m
This may take a while!!!!"
openvas-nvt-sync
echo ok!

echo -e "\e[31mStarting OpenVas Scanner.\e[0m"
openvassd
echo ok!

echo -e "\033[31mRebuilding database......\033[m
This may take a while!!!!"
openvasmd --migrate
openvasmd --rebuild
echo ok!

echo -e "\e[31mStarting OpenVas Manager.\e[0m"
openvasmd -p 9390 -a 127.0.0.1
echo ok!

echo -e "\e[31mStarting OpenVas Administrator.\e[0m"
openvasad -a 127.0.0.1 -p 9393
echo ok!

echo -e "\e[31mStarting Greenbone Security Assistant.\e[0m"
gsad --http-only --listen=127.0.0.1 -p 9392
echo ok! All should be good!

#is it up openvas scanner
echo -e "$execstyle Checking if OpenVas Scanner is running..."
ps -ef | grep -v grep | grep openvassd
if [ $? -eq 1 ]
 then
	echo -e "$warnstyle OpenVas Scanner not running!" 
 else
	echo -e "$infostyle OpenVas Scanner is running!!"
fi

#is it up openvas administrator
echo -e "$execstyle Checking if OpenVas Administrator is running..."
ps -ef | grep -v grep | grep openvasad
if [ $? -eq 1 ]
 then
	echo -e "$warnstyle OpenVas Administrator not running!" 
 else
	echo -e "$infostyle OpenVas Administrator is running!!"
fi

#is it up openvas manager
echo -e "$execstyle Checking if OpenVas Manager is running..."
ps -ef | grep -v grep | grep openvasmd
if [ $? -eq 1 ]
 then
	echo -e "$warnstyle OpenVas Manager not running!" 
 else
	echo -e "$infostyle OpenVas Manager is running!!"
fi

#is it up Greenbone Security Assistant
echo -e "$execstyle Checking if Greenbone Security Assistant is running..."
ps -ef | grep -v grep | grep gsad
if [ $? -eq 1 ]
 then
	echo -e "$warnstyle Greenbone Security Assistant not running!" 
 else
	echo -e "$infostyle Greenbone Security Assistant is running"
fi

#### all done!
echo
echo -e "\033[01;32mOK!!\033[m"
echo -e "\033[31mAll Done!! :) \033[m
OpenVas is running!! Open browser to 127.0.0.1:9392 or open Green Bone Security Desktop."
}

########openvasstop
function openvasstop {
# style variables
execstyle="[\e[01;32mx\e[00m]" # execute msgs style
warnstyle="[\e[01;31m!\e[00m]" # warning msgs style
infostyle="[\e[01;34mi\e[00m]" # informational msgs style

#fun little banner
clear
echo -e "\e[01;32m
####### ######  ####### #     # #     #    #     #####  
#     # #     # #       ##    # #     #   # #   #     # 
#     # #     # #       # #   # #     #  #   #  #       
#     # ######  #####   #  #  # #     # #     #  #####  
#     # #       #       #   # #  #   #  #######       # 
#     # #       #       #    ##   # #   #     # #     # 
####### #       ####### #     #    #    #     #  #####  
                                                        
\e[0m"
echo -e "\e[1;1m   ..----=====*****(( Shutdown Script ))*******=====----..\e[0m"
echo -e "\e[31m *************************************************************\e[0m"
echo -e "\e[31m *                                                           *\e[0m"
echo -e "\e[31m *              \e[1;37mStopping All OpenVas Services \e[0;31m               *\e[0m"
echo -e "\e[31m *                                                           *\e[0m"
echo -e "\e[31m *************************************************************\e[0m"

#kill openvas scanner
echo -e "$execstyle Checking OpenVas Scanner is running..."
ps -ef | grep -v grep | grep openvassd
if [ $? -eq 1 ]
 then
	echo -e "$warnstyle OpenVas Scanner not running!" 
 else
	echo -e "$execstyle Stopping OpenVas Scanner..."
	killall openvassd
	echo -e "$infostyle OpenVas Scanner is dead!!"
fi

#kill openvas administrator
echo -e "$execstyle Checking if OpenVas Administrator is running..."
ps -ef | grep -v grep | grep openvasad
if [ $? -eq 1 ]
 then
	echo -e "$warnstyle OpenVas Administrator not running!" 
 else
	echo -e "$execstyle Stopping OpenVas Administrator..."
	killall openvasad
	echo -e "$infostyle OpenVas Administrator is dead!!"
fi

#kill openvas manager
echo -e "$execstyle Checking if OpenVas Manager is running..."
ps -ef | grep -v grep | grep openvasmd
if [ $? -eq 1 ]
 then
	echo -e "$warnstyle OpenVas Manager not running!" 
 else
	echo -e "$execstyle Stopping OpenVas Manager..."
	killall openvasmd
	echo -e "$infostyle OpenVas Manager is dead!!"
fi

#kill Greenbone Security Assistant
echo -e "$execstyle Checking if Greenbone Security Assistant is running..."
ps -ef | grep -v grep | grep gsad
if [ $? -eq 1 ]
 then
	echo -e "$warnstyle Greenbone Security Assistant not running!" 
 else
	echo -e "$execstyle Stopping Greenbone Security Assistant..."
	killall gsad
	echo -e "$infostyle Greenbone Security Assistant is dead!!"

fi

#### all done!
echo
echo -e "\033[01;32m All Done!! :) \033[m"
}

######## Rollback Openvas to Version 5
function rollbackopenvas {
echo -e "\033[31mThis script will roll OpenVas back to Version 5\033[m"
echo -e "\033[31myou may need this if you broke Openvas with apt-get dist-upgrade\033[m"
echo "Do you want to rollback ? (Y/N)"
read install
if [[ $install = Y || $install = y ]] ; then	
		echo -e "\033[31m====== Rolling OpenVas back to V5 ======\033[m"
		apt-get remove --purge greenbone-security-assistant libopenvas6 openvas-administrator openvas-manager openvas-cli openvas-scanner
		mkdir openvasfix
		cd openvasfix
		if [ $(uname -m) == "x86_64" ] ; then
			#64 bit system
			wget http://repo.kali.org/kali/pool/main/o/openvas-manager/openvas-manager_3.0.4-1kali0_amd64.deb
			wget http://repo.kali.org/kali/pool/main/o/openvas-administrator/openvas-administrator_1.2.1-1kali0_amd64.deb
			wget http://repo.kali.org/kali/pool/main/o/openvas-cli/openvas-cli_1.1.5-1kali0_amd64.deb
			wget http://repo.kali.org/kali/pool/main/o/openvas-scanner/openvas-scanner_3.3.1-1kali1_amd64.deb
			wget http://repo.kali.org/kali/pool/main/o/openvas/openvas_1.1_amd64.deb
			wget http://repo.kali.org/kali/pool/main/g/greenbone-security-assistant/greenbone-security-assistant_3.0.3-1kali0_amd64.deb
			wget http://repo.kali.org/kali/pool/main/libo/libopenvas/libopenvas5_5.0.4-1kali0_amd64.deb
		else
			#32 bit system
			wget http://repo.kali.org/kali/pool/main/o/openvas-manager/openvas-manager_3.0.4-1kali0_i386.deb
			wget http://repo.kali.org/kali/pool/main/o/openvas-administrator/openvas-administrator_1.2.1-1kali0_i386.deb
			wget http://repo.kali.org/kali/pool/main/o/openvas-cli/openvas-cli_1.1.5-1kali0_i386.deb
			wget http://repo.kali.org/kali/pool/main/o/openvas-scanner/openvas-scanner_3.3.1-1kali1_i386.deb
			wget http://repo.kali.org/kali/pool/main/o/openvas/openvas_1.1_i386.deb
			wget http://repo.kali.org/kali/pool/main/g/greenbone-security-assistant/greenbone-security-assistant_3.0.3-1kali0_i386.deb
			wget http://repo.kali.org/kali/pool/main/libo/libopenvas/libopenvas5_5.0.4-1kali0_i386.deb
		fi
		dpkg -i *
		apt-get install gsd kali-linux kali-linux-full
		wget --no-check-certificate https://svn.wald.intevation.org/svn/openvas/trunk/tools/openvas-check-setup
		chmod +x openvas-check-setup
		./openvas-check-setup --v5
		else
			echo -e "\e[32m[-] Ok,maybe later !\e[0m"
		fi
		echo -e "\e[32m[-] Done!\e[0m"	
}

### Update Exploitdb
function updateexploitdb {
	echo -e "\033[31mThis script will update your Exploitdb\033[m"
	cd /usr/share/exploitdb
	rm -rf archive.tar.bz2
	wget http://www.exploit-db.com/archive.tar.bz2
	tar xvfj archive.tar.bz2
	rm -rf archive.tar.bz2
	echo -e "\e[32m[-] Done Updating Exploitdb!\e[0m"	
}

#### Searchsploit
function searchsploit {
	echo -e "\033[31mWhat do you want to Hack Today?\033[m"
	echo -e "\033[31mEnter a search term and hit Enter\033[m"
	read searchterm
	gnome-terminal --maximize -t "Seachsploit" --working-directory=WORK_DIR -x bash -c "searchsploit $searchterm; echo -e '\e[32m[-] Close this window when done!\e[0m'; bash" 2>/dev/null & sleep 2
	
}

#### Install Subterfuge
function installsubterfuge {
	echo "This will install Subterfuge. Do you want to install it ? (Y/N)"
	read install
	if [[ $install = Y || $install = y ]] ; then
		echo -e "\e[31m[+] Installing Subterfuge now!\e[0m"
		cd /tmp
		wget http://subterfuge.googlecode.com/files/SubterfugePublicBeta5.0.tar.gz
		tar zxvf SubterfugePublicBeta5.0.tar.gz
		cd subterfuge
		python install.py
		cd ../
		rm -rf subterfuge/
		rm SubterfugePublicBeta5.0.tar.gz
		echo -e "\e[32m[-] Done Installing Subterfuge!\e[0m"		
	else
		echo -e "\e[32m[-] Ok,maybe later !\e[0m"
	fi
}
##### Subterfuge
function subterfuge {
	if [ ! -f /usr/local/bin/unicornscan ]; then
			installsubterfuge
		else
			echo "Subterfuge is installed."
			echo -e "\e[31m[+] Launching Subterfuge now!\e[0m"
			echo "leave the window that opens open until done using."
			gnome-terminal -t "Subterfuge" -e subterfuge 2>/dev/null & sleep 2			
		fi	
}

##### Ghost-Phisher
function ghostphisher {
	if [ ! -f /opt/Ghost-Phisher/ghost.py ]; then
			installghostphisher
		else
			echo "Ghost-Phisher is installed."
			echo -e "\e[31m[+] Launching Ghost-Phisher now!\e[0m"
			python /opt/Ghost-Phisher/ghost.py 2>/dev/null & sleep 2			
		fi	
}

######## Install Ghost-Phisher
function installghostphisher {
	echo "This will install Ghost-Phisher. Do you want to install it ? (Y/N)"
	read install
	if [[ $install = Y || $install = y ]] ; then
		echo -e "\e[31m[+] Installing Ghost-Phisher now!\e[0m"
		cd /tmp
		wget http://ghost-phisher.googlecode.com/files/Ghost-Phisher_1.5_all.deb
		dpkg -i Ghost-Phisher_1.5_all.deb
		rm Ghost-Phisher_1.5_all.deb
		echo -e "\e[32m[-] Done Installing GhostFisher!\e[0m"		
	else
		echo -e "\e[32m[-] Ok,maybe later !\e[0m"
	fi
	
	
}

######## Install Flash
function installflash {
	echo "This will install Flash. Do you want to install it ? (Y/N)"
	read install
	if [[ $install = Y || $install = y ]] ; then
		echo -e "\e[31m[+] Installing Flash now!\e[0m"
		apt-get -y install flashplugin-nonfree
		update-flashplugin-nonfree --install
		echo -e "\e[32m[-] Done Installing Flash!\e[0m"		
	else
		echo -e "\e[32m[-] Ok,maybe later !\e[0m"
	fi
	
	
}

######## Install smbexec
function installsmbexec {
	echo "This will install Smbexec. Do you want to install it ? (Y/N)"
	read install
	if [[ $install = Y || $install = y ]] ; then
		echo -e "\e[31m[+] Installing Smbexec now!\e[0m"
		cd /opt
		git clone https://github.com/brav0hax/smbexec.git
		cd smbexec
		./install.sh
		echo -e "\e[32m[-] Done Installing Smbexec part 1!\e[0m"
		echo -e "\e[31m[+] Now for part 2 Compile the binaries, select option 4!\e[0m"
		./install.sh
		echo -e "\e[32m[-] Done Installing Smbexec!\e[0m"
		echo "Open a terminal and type smbexec, have fun!"		
	else
		echo -e "\e[32m[-] Ok,maybe later !\e[0m"
	fi
	
	
}	

######## Install xssf
function installxssf {
	echo "This will install Xssf. Do you want to install it ? (Y/N)"
	read install
	if [[ $install = Y || $install = y ]] ; then
		echo -e "\e[31m[+] Installing Xssf now!\e[0m"
		cd /opt/metasploit/apps/pro/msf3
		svn export http://xssf.googlecode.com/svn/trunk ./ --force
		echo -e "\e[32m[-] Done Installing Xssf!\e[0m"
		echo -e "\e[32m[-]Open a terminal launch msfconsole \n   then inside metasploit type 'load xssf Port=666' or what everport number you want\e[0m"
	else
		echo -e "\e[32m[-] Ok,maybe later !\e[0m"
	fi
}	

######### Install extras
function extras {
clear
echo -e "
\033[31m#######################################################\033[m
                Install Extras
\033[31m#######################################################\033[m"

select menusel in "Bleeding Edge Repos" "Hackpack" "Google Chrome" "Flash" "Smbexec" "Xssf" "Ettercap 0.76" "AngryIP Scanner" "Terminator" "Xchat" "Unicornscan" "Nautilus Open Terminal" "Simple-Ducky" "Subterfuge" "Ghost-Phisher" "Java" "Install All" "Back to Main"; do
case $menusel in
	"Bleeding Edge Repos")
		bleedingedge
		pause 
		extras;;
		
	"Hackpack")
		installhackpack
		pause
		extras;;
		
	"Google Chrome")
		installgooglechrome
		pause 
		extras;;
		
	"Flash")
		installflash
		pause 
		extras;;
		
	"Smbexec")
		installsmbexec
		pause 
		extras;;
		
	"Xssf")
		installxssf
		pause 
		extras;;
				
	"Ettercap 0.76")
		installettercap
		pause 
		extras ;;
	
	"AngryIP Scanner")
		installangryip
		pause
		extras  ;;
		
	"Terminator")
		installterminator
		pause
		extras  ;;

	"Xchat")
		installxchat
		pause
		extras  ;;
			
	"Unicornscan")
		installunicornscan
		pause
		extras ;;
		
	"Nautilus Open Terminal")
		installnautilusopenterm
		pause
		extras ;;
		
	"Simple-Ducky")
		installsimpleducky
		pause
		extras ;;
		
	"Subterfuge")
		installsubterfuge
		pause
		extras ;;
		
	"Ghost-Phisher")
		installghostphisher
		pause
		extras ;;
		
	"Java")
		installjava
		pause
		extras ;;
		
	"Install All")
		echo -e "\e[36mJava is install seperately choose it from the extra's menu\e[0m"
		echo -e "\e[31m[+] Installing Extra's\e[0m"
		bleedingedge
		installhackpack
		installgooglechrome
		installflash
		installangryip
		installterminator
		installxchat
		installsmbexec
		installxssf
		installunicornscan
		installnautilusopenterm
		installsimpleducky
		installghostphisher
		installsubterfuge
		echo -e "\e[32m[-] Done Installing Extra's\e[0m"
		pause
		extras ;;
		

	"Back to Main")
		clear
		mainmenu ;;
		
	*)
		screwup
		extras ;;
	
		
esac

break

done
}
########################################################
##             Main Menu Section
########################################################
function mainmenu {
echo -e "
\033[31m################################################################\033[m
\033[1;36m
.____                           ____  __.      .__  .__ 
|    |   _____  ___________.__.|    |/ _|____  |  | |__|
|    |   \__  \ \___   <   |  ||      < \__  \ |  | |  |
|    |___ / __ \_/    / \___  ||    |  \ / __ \|  |_|  |
|_______ (____  /_____ \/ ____||____|__ (____  /____/__|
        \/    \/      \/\/             \/    \/         

\033[m                                        
                   Script by Reaperz73
                    version : \033[32m$version\033[m
Script Location : \033[32m$0\033[m
Connection Info :-----------------------------------------------
  Gateway: \033[32m$DEFAULT_ROUTE\033[m Interface: \033[32m$IFACE\033[m My LAN Ip: \033[32m$MYIP\033[m
\033[31m################################################################\033[m"

select menusel in "Update Kali" "Metasploit Services" "OpenVas Services" "Exploitdb" "Sniffing/Spoofing" "Install Extras" "Payload Gen" "HELP!" "Credits" "EXIT PROGRAM"; do
case $menusel in
	"Update Kali")
		updatekali
		clear ;;
	
	"Metasploit Services")
		metasploitservices
		clear ;;
			
	"OpenVas Services")
		OpenVas
		clear ;;
		
	"Exploitdb")
		exploitdb
		clear ;;
	
	"Sniffing/Spoofing")
		sniffspoof
		clear ;;
	
	"Install Extras")
		extras 
		clear ;;

	"Payload Gen")
		payloadgen
		clear ;;
	
	"HELP!")
		echo "What do you need help for, seems pretty simple!"
		pause
		clear ;;
		
	"Credits")
		credits
		pause
		clear ;;

	"EXIT PROGRAM")
		clear && exit 0 ;;
		
	* )
		screwup
		clear ;;
esac

break

done
}

while true; do mainmenu; done
