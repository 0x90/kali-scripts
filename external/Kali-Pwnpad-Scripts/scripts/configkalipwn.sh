#!/bin/bash
#
# Set up script for new logins / passwords
#
##################################################################
#                   		MENU                                 #
##################################################################
f_interface(){
clear
echo "************************"
toilet -f standard -F metal "KaliPWN Config"
echo "************************"
echo "[1] SSH Keys Generate/Copy"
echo "[2] Update Kalipwn Scripts"
echo "[3] Update Everything (Metasplit/OpenVAS/Kali)"
echo "[4] Create New Metasploit Postgresql Database/User"
echo "[5] Change VNC password (default kalipwn)"
echo "[6] OpenVAS Maintenance"
echo "[7] Configure Timezone"
echo "#### VNC Maintenance #####"
echo "[8] Kill all VNC instances (remove pid/logs)"
echo "[9] Start VNC server"
echo "#### VPN Server #####"
echo "[10] Generate/Start VPN server"
echo "##########################"
echo "[0] Exit"
echo -n "Enter your menu choice [1-10]: "

# wait for character input

read -p "Choice:" menuchoice

case $menuchoice in

1) f_sshkeys ;;
2) f_updatescripts ;;
3) f_updateall ;;
4) f_metasploit ;;
5) f_vncpasswd ;;
6) f_openvas ;;
7) f_timezone ;;
8) f_vnckill ;;
9) f_vncstart ;;
10) f_vpnmenu ;;
0) exit 0 ;;
*) echo "Incorrect choice..." ;
esac
}

##################################################################
#                        SSH KEYS                                #
##################################################################
f_sshkeys(){
clear
echo "SSH Configuration"
echo "[1] Generate new SSH keys"
echo "[2] Copy SSH keys to SDCARD"
echo "[3] Exit to main menu"
echo -n "Enter your menu choice [1-3]: "
read -p "Choice:" sshstart

case $sshstart in
1) f_sshkeys_generate ;;
2) f_sshkeys_copy ;;
3) f_interface ;;
*) echo "Incorrect choice..." ;
esac
}

f_sshkeys_generate(){
	clear
	echo "Generating new SSH keys and removing old ones."
	echo "Password is optional and NOT recommended for automatic login."
	sleep 3
	cd ~/.ssh/
	rm *
	sleep 3
	ssh-keygen -t rsa
	echo "Creating authorized_keys file for passwordless login in ~/.ssh/"
	sleep 1
	cat id_rsa.pub > authorized_keys
	echo "Finished!"
	sleep 2
	f_interface
}

f_sshkeys_copy(){
clear
	cd "/root/.ssh"
	echo "Zipping SSH key 'id_rsa'"
	zip "/sdcard/ssh_key.zip" "id_rsa"
	echo "File copied to /sdcard/ssh_key.zip"
	sleep 5
	f_sshkeys
}

##################################################################
#                   Update KaliPWN Scripts                       #
##################################################################
NOW=$(date +"%m-%d-%y-%H%M%S")

f_updatescripts() {
	clear
	echo "This will pull scripts from Github. This will not check for updates."  
	echo "If you have made any changes to the scripts you should not run this."
	read -p "Do you wish to continue? (y/n)" CONT

if [ "$CONT" == "y" ]; then

	echo "Creating backup of old scripts in /opt/pwnpad/scripts/backup_scripts$NOW.zip"
	sleep 3
	cd /opt/pwnpad/scripts/
	zip -p "backup_scripts$NOW.zip" *.sh
	echo "Downloading scripts to temporary folder (/tmp)"
	sleep 2
	mkdir -p /tmp
	cd /tmp/
	git clone https://github.com/binkybear/Kali-Pwnpad-Scripts.git
	echo "Copying scripts to /opt/pwnpad/scripts"
	cp Kali-Pwnpad-Scripts/scripts/* /opt/pwnpad/scripts
	cd /opt/pwnpad/scripts/
	chmod +x *.sh
	echo "Removing temporary downloads"
	rm -rf /tmp/Kali-Pwnpad-Scripts
	f_interface
else
	f_interface
fi	
}
##################################################################
#                   Update Metasploit                            #
##################################################################
f_updateall(){
	clear
	echo "Updating Kali..."
	sleep 2
	apt-get update && apt-get -y upgrade && apt-get clean
	echo "Updating Metasploit (this could take a while)...."	
	sleep 2
	msfupdate
	echo "Updating OpenVAS"
	sleep 2
	openvas-nvt-sync
	f_interface
}
##################################################################
#                   VNC Password Change                          #
##################################################################
f_vncpasswd(){
	clear
	echo "Change your VNC password:"
	vncpasswd
	f_interface
}
##################################################################
#                   Generate metasploit user/db                  #
##################################################################
f_metasploit() {
	service postgresql
	echo "Switching to user postgres"
	su postgres	
	read -p "Enter Metasploit database username:" msuser
	createuser -D -P -R -S $msuser
	read -p "Enter Metasploit database name:" dbname
	createdb --owner=$msuser $dbname
	su root
	echo "You can now add database connection to startup at ~/.msf4/msfconsole.rc"
	echo "Just add:"
	echo "db_connect $msuser:YOURPASSWORD@127.0.0.1:5432/$dbname"
	sleep 4
	f_interface
	}
##################################################################
#                   OpenVAS Main.                                #
##################################################################
f_openvas(){
clear
echo "OPENVAS CONFIGURATION MENU"
echo "[1] Add User"
echo "[2] Remove User"
echo "[3] Make Certificates"
echo "[4] Exit to main menu"
echo -n "Enter your menu choice [1-4]: "
read -p "Choice:" vasmenuchoice

case $vasmenuchoice in
1) openvas-adduser ;;
2) openvas-rmuser ;;
3) openvas-mkcert ;;
4) f_interface ;;
*) echo "Incorrect choice..." ;
esac
}
##################################################################
#                   CHANGE TIMEZONE                              #
##################################################################
f_timezone(){
	dpkg-reconfigure tzdata;
	f_interface
}

##################################################################
#                   KILL ALL VNC                                 #
##################################################################
f_vnckill(){
	echo "Removing all PID and log files from /root/.vnc/"
	echo "Killing all VNC process ID's"
	sleep 2
	kill $(ps aux | grep 'Xtightvnc' | awk '{print $2}')
	echo "Removing PID files"
	sleep 2
	vncdisplay=$(ls ~/.vnc/*.pid | sed -e s/[^0-9]//g)
	for x in $vncdisplay; do tightvncserver -kill :$x; done;
	echo "Removing log files"
	sleep 2
	rm /root/.vnc/*.log;
	echo "Removing lock file"
	sleep 2
	rm -r /tmp/.X*
	echo "All VNC process/logs have hopefully been removed"
	sleep 3
	f_interface
}
##################################################################
#                   VNC START                                    #
##################################################################
f_vncstart(){
clear
echo "VNC START MENU"
echo "[1] Start Nexus 7 (2012) - 1280x1024"
echo "[2] Start Nexus 7 (2013) - 1920x1200"
echo "[3] Custom Display Size"
echo "[4] Exit to main menu"
echo -n "Enter your menu choice [1-4]: "
read -p "Choice:" vncmenustart

case $vncmenustart in
1) vncserver -geometry 1280x1024 -depth 24 && echo "Display Number :X will be port 590X." && read -p "Press any key to continue..." && f_interface ;;
2) vncserver -geometry 1920x1200 -depth 24 && echo "Display Number :X will be port 590X." && read -p "Press any key to continue..." && f_interface ;;
3) f_customvnc ;;
4) f_interface ;;
*) echo "Incorrect choice..." ;
esac
}

f_customvnc(){
	read -p "Enter Custom Display Size e.g.: 1280x1024" CUSTOMVNCSIZE
	vncserver -geometry $CUSTOMVNCSIZE -depth 24
	echo "Display Number :X will be port 590X." && read -p "Press any key to continue..." && f_interface
}

##################################################################
#                   GENERATE VPN SERVER                          #
##################################################################
f_vpnmenu(){
clear
echo "[1] Build VPN Server Keys (*warning* removes previous old ones)"
echo "[2] Use current public IP (*warning* port forwarding must be open on port 1194 )"
echo "[3] Use local IP (wlan0)"
echo "[4] Use custom domain or dynamic DNS"
echo "[5] Export Client Keys to SDCARD"
echo "[6] Start VPN Server"
echo "[7] Exit to Main Menu"
echo -n "Enter your menu choice [1-6]: "
read -p "Choice:" vpnkeychoice

case $vpnkeychoice in
1) f_server_key ;;
2) f_public_clientkey ;;
3) f_localip_clientkey ;;
4) f_domain_clientkey ;;
5) f_exportkeys ;;
6) f_startvpn ;;
7) f_interface ;;
*) echo "Incorrect choice..." ;
esac
}

f_server_key(){
echo "Checking Dependencies"
sleep 3
apt-get update
apt-get install openvpn openssl zip
cd /etc/openvpn
echo "Removing previous server..."
rm -rf easy-rsa
cp -r /usr/share/doc/openvpn/examples/easy-rsa/2.0 ./easy-rsa
cd /etc/openvpn/easy-rsa
echo 'export EASY_RSA="/etc/openvpn/easy-rsa"' >> vars
source vars
./clean-all
./pkitool --initca
ln -s openssl-1.0.0.cnf openssl.cnf
echo "Building Server Certificates"
sleep 3
echo "Generating Certificate Authority Key..."
./build-ca OpenVPN
echo "Generating Server Key..."
./build-key-server server
echo "Generating client1 Key..."
./build-key client1
./build-dh
cd /etc/openvpn
echo "Creating configuration file in /etc/opevpn/openvpn.conf"
cat << EOF > /etc/openvpn/openvpn.conf
dev tun
proto udp
port 1194
ca /etc/openvpn/easy-rsa/keys/ca.crt
cert /etc/openvpn/easy-rsa/keys/server.crt
key /etc/openvpn/easy-rsa/keys/server.key
dh /etc/openvpn/easy-rsa/keys/dh1024.pem
user nobody
group nogroup
server 10.8.0.0 255.255.255.0
persist-key
persist-tun
status f
verb 3
client-to-client
push "redirect-gateway def1"
#set the dns servers
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
log-append /var/log/openvpn
comp-lzo
EOF
# RETURN TO VPN MENU
f_vpnmenu
}

f_public_clientkey(){
clear
PUBLIC_IP=$(curl www.icanhazip.com)
echo "Using IP:$PUBLIC_IP in kalipwn.ovpn client configuration file"
sleep 5
cat << EOF > /etc/openvpn/easy-rsa/keys/kalipwn.ovpn
dev tun
client
proto udp
remote $PUBLIC_IP 1194
resolv-retry infinite
nobind
persist-key
persist-tun
ca ca.crt
cert client1.crt
key client1.key
comp-lzo
verb 3	
EOF
echo "Finished. Returning to menu."
sleep 5
# RETURN TO VPN MENU
f_vpnmenu
}

f_localip_clientkey(){
clear
LOCAL_IP=$(ifconfig wlan0 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
echo "Using IP:$LOCAL_IP in kalipwn.ovpn client configuration file"
sleep 5
cat << EOF > /etc/openvpn/easy-rsa/keys/kalipwn.ovpn
dev tun
client
proto udp
remote $LOCAL_IP 1194
resolv-retry infinite
nobind
persist-key
persist-tun
ca ca.crt
cert client1.crt
key client1.key
comp-lzo
verb 3	
EOF
echo "Finished. Returning to menu."
sleep 5
# RETURN TO VPN MENU
f_vpnmenu
}

f_domain_clientkey(){
clear
read -p "Enter custom domain/IP/dynamic IP:" DOMAIN_IP
cat << EOF > /etc/openvpn/easy-rsa/keys/kalipwn.ovpn
dev tun
client
proto udp
remote $DOMAIN_IP 1194
resolv-retry infinite
nobind
persist-key
persist-tun
ca ca.crt
cert client1.crt
key client1.key
comp-lzo
verb 3	
EOF
echo "Finished. Returning to menu."
sleep 5
# RETURN TO VPN MENU
f_vpnmenu
}

f_exportkeys(){
echo "Zipping client keys to /sdcard/openvpn-kalipwn-clientcert.zip"
sleep 5
cd /etc/openvpn/easy-rsa/keys/
zip -r6 /sdcard/openvpn-kalipwn-clientcert.zip ca.crt ca.key client1.crt client1.csr client1.key kalipwn.ovpn
echo "If you received an error things may have gone wrong when generating a certificate..."
sleep 6
# RETURN TO VPN MENU
f_vpnmenu
}

f_startvpn(){
echo "Starting OpenVPN on wlan0"
sleep 3
echo "1" > /proc/sys/net/ipv4/ip_forward
iptables -t nat -A POSTROUTING -s 10.0.0.0/8 ! -d 10.0.0.0/8 -o wlan0 -j MASQUERADE
service openvpn start
echo "Started." 
echo "Don't forget to run Android application 'Wake Lock' to prevent disconnects..."
sleep 5
f_vpnmenu
}
##################################################################
f_interface
