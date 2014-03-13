#!/bin/bash
###### Kali Linux Auto-Update script ######
###### Steps: 
###### 1. Manually download Adobe Flash Player for "Other linux" (the option that gives you a .tar.gz package)
###### 2. If desired, Manually download Nessus for Debian Linux  and request a home or professional feed for it
###### 3. Copy the adobe .tar.gz package, the nessus .deb package, and the updater.sh script to "/"
###### 4. As root, run: "bash updater.sh"
###### 5. Watch the magic happen

########################################

# Logging setup. Ganked this entirely from stack overflow. Uses named pipe magic to log all the output of the script to a file. Also capable of accepting redirects/appends to the file for logging compiler stuff (configure, make and make install) to a log file instead of losing it on a screen buffer. This gives the user cleaner output, while logging everything in the background, in the event they need to send it to me for analysis/assistance.

logfile=/var/log/kali_updater.log
mkfifo ${logfile}.pipe
tee < ${logfile}.pipe $logfile &
exec &> ${logfile}.pipe
rm ${logfile}.pipe

########################################
#Metasploit-like print statements: status, good, bad and notification. Gratouitiously copied from Darkoperator's metasploit install script.

function print_status ()
{
    echo -e "\x1B[01;34m[*]\x1B[0m $1"
}

function print_good ()
{
    echo -e "\x1B[01;32m[*]\x1B[0m $1"
}

function print_error ()
{
    echo -e "\x1B[01;31m[*]\x1B[0m $1"
}

function print_notification ()
{
	echo -e "\x1B[01;33m[*]\x1B[0m $1"
}

########################################

#this is a function for checking whether or not a task completed with a 0 (full success) status or not. If the status is anything BUT 0, the script bails. You should check the log as to why, or let me know. Either way, something went boom.

function success_check
{
if [ $? -eq 0 ]; then
  print_good "Procedure successful."
 else
  print_error "Procedure unsucessful! check $logfile for details. Bailing."
  exit 1
 fi
}

########################################

########################################
##BEGIN MAIN SCRIPT
########################################

#root priv check. We mess with a lot of system things, so we need to be running as root.

print_status "Checking for root privs."
if [ $(whoami) != "root" ]; then
	print_error "This script must be ran with sudo or root privileges, or this isn't going to work."
	exit 1
else
	print_good "We are root."
fi

########################################

#This reconfigures sshd on kali (it's not running by default) -- it deletes the old host keys, regenerates then, configures sshd to run on startup, then starts the service.

print_status "Reconfiguring sshd."

print_status "Removing old host keys.."
rm -rf /etc/ssh/ssh_host_* &>> $logfile
success_check

print_status "Regenerating host keys.."
dpkg-reconfigure openssh-server &>> $logfile
success_check

print_status "Reconfiguring sshd to start on boot"
update-rc.d ssh enable &>> $logfile
success_check

print_status "Starting sshd"
service ssh start &>> $logfile
success_check

print_status "Printing sshd status"
service ssh status

########################################

#adding the kali bleeding edge repo, cuz if it aint' bleeding, it aint for me.

print_status "Adding kali bleeding edge repo to /etc/apt/sources.list.."
echo "" >> /etc/apt/sources.list
echo "#Kali bleeding repository" >> /etc/apt/sources.list
echo "deb http://repo.kali.org/kali kali-bleeding-edge main" >> /etc/apt/sources.list
success_check

########################################

#This is where we actually install system updates. Runs apt-get update and apt-get -y dist-upgrade.
#Why a dist-upgrade? because for one reason or another, there are several packages that get "held back"
#With a regular apt-get upgrade. Dist upgrade forces those held back packages to be updated as well.
#On a normal linux distro, you wouldn't do this unless you wanted to do a full distro upgrade, but to my knowledge, for Kali that should be fine.
#This takes a long time, dist-upgrade or no. updating Kali takes a long time, because it pulls like 400+ packages.

print_status "Performing apt-get update"
apt-get update &>> $logfile
success_check

print_status "Performing apt-get upgrade"
print_notification "This WILL take a while. I'm talking at least half an hour (probably longer) on a good connection and fast system. Be patient."
print_notification "You can monitor the programs through running (in another terminal window):"
print_notification "tail -f $logfile"
apt-get -y dist-upgrade &>> $logfile
success_check

########################################

#Now we run 

print_status "Running msfupdate"
print_notification "This may also take a little while to run. Not nearly as long as a full update did."
msfupdate &>> $logfile
success_check

########################################

#This portion of the script checks to see if the flash player package is located in "/" (the root directory)
#If it's there, untar it, and install it. If not, move on to the next section.

if [ -e /install_flash_player_*_linux.x86_64.tar.gz ]; then
	print_status "Installing Flash Player for Linux (required for nessus console).."
	print_status "Untarring package.."
	tar -xzvf install_flash_player_*_linux.x86_64.tar.gz &>> $logfile
	success_check
	print_status "Copying plugin to /usr/lib/mozilla/plugins/.."
	cp libflashplayer.so /usr/lib/mozilla/plugins/ &>> $logfile
	success_check
else
	print_notification "Flash Player installation package not found in /, moving on."
fi

########################################

#This portion of the script checks to see if a nessus .deb package exists in "/" (again, the root directory)
#If it does, dpkg installs it and it is configured to start up on boot.
#If you have a valid product key, uncomment the line nessus_key= and put your nessus key here
#Uncomment all the commented lines below that, and nessus will auto-register and auto-update all its plugins.

if [ -e /Nessus-*-debian*_amd64.deb ]; then
	print_status "Installing Nessus.."
	dpkg -i Nessus-*-debian*_amd64.deb &>> $logfile
	success_check
	##Insert your nessus product key here (dashes and all)
	#The key will look something like:
	#xxxx-xxxx-xxxx-xxxx-xxxx
	#if you have a nessus key already, you can enable this part by removing the comments (hash marks[#])
	#nessus_key=
	#print_status "Registering Nessus." 
	#print_notification "Make sure you included a valid Corporate or Home feed license in this script!"
	#/opt/nessus/bin/nessus-fetch --register $nessus_key &>> $logfile
	#success_check
	print_status "Added nessusd to default run-levels."
	update-rc.d -f nessusd defaults &>> $logfile
	success_check
	print_notification "Don't forget! you NEED to register nessus before attempting to use it.. if you didn't uncomment that part of the script and did that already."
	print_notification "This can be done via:"
	print_notification "/opt/nessus/bin/nessus-fetch --register [your nessus key here]"
else
	print_notification "nessus installer package not found in /, moving on."
fi
########################################

#This portion of the script installs some nice-to-have packages that, for some reason or another are _not_ installed by default on Kali. 
#Frankly I have no idea why, but this portion is here to fix that.

print_status "Installing armitage, mimikatz, terminator, unicornscan, and zenmap.."
apt-get -y install armitage mimikatz terminator unicornscan zenmap &>> $logfile
success_check
print_notification "Newly installed tools should be located on your default PATH."

########################################

#This is a simple git pull of the Cortana .cna script repository available on github.

print_status "Grabbing Armitage Cortana Scripts via github.."
git clone http://www.github.com/rsmudge/cortana-scripts.git /opt/cortana &>> $logfile
success_check
print_notification "Cortana scripts installed under /opt/cortana."

########################################

#This is an svn pull of the unsploitable set of tools available on sourceforge.
#Unsploitable is essentially a set of scripts that, when fed a set of nessus scans, can map a vulnerability to a specific patch (e.g. tell you what patch fixes what vulnerability)

print_status "Pulling Unsploitable.."
mkdir /opt/other-tools
cd /opt/other-tools
svn checkout svn://svn.code.sf.net/p/unsploitable/code/trunk unsploitable &>> $logfile
success_check
print_notification "Unsploitable installed to /opt/other-tools/unsploitable"

########################################

#This is an svn pull of defense tools for the blind
#The DTFTB scripts are a set of tools that are CTF oriented. 
#These are tools and scripts that are meant to be run on a target system that you are either defending (blue team) or gained access to and have to maintain that access from enemy teams (KOTH-style gameplay)

print_status "Pulling DTFTB (Defense Tools for the Blind)"
svn checkout svn://svn.code.sf.net/p/dtftb/code/trunk dtftb &>> $logfile
success_check
print_notification "DTFTB installed to /opt/other-tools/dtftb"

########################################

#This last portion of the script pulls smbexec from brav0hax's github.
#this is a stand-alone smbexec tool based off of samba
#its primary use is for gaining access to system with security products in place that will flag on service creation, or just are aware of tactics used 
#by metasploit's default smbexec module.
#The script has to be ran twice. The first time, the script grabs the prereqs, etc required to compile smbexec
#The second time around, it compiles smbexec, actually installing it.

print_status "Pulling SMBexec."
print_notification "This pulls somewhere north of 180mb of data. It's going to take a bit of time."
git clone https://github.com/brav0hax/smbexec.git /opt/other-tools/smbexec-source &>> $logfile
success_check
cd /opt/other-tools/smbexec-source
print_status "Performing Installation pre-reqs."
print_notification "The installation is scripted. When prompted for what OS you are using choose Debian or Ubuntu variant."
print_notification "When prompted for where to install smbexec, select /opt/other-tools/smbexec-source"
print_notification "Select option 5 to exit, if prompted."
read -p "You'll have to run the installer twice. The script immediately bails after installing pre-reqs. Hit enter to continue." pause_1
bash install.sh
success_check
print_status "Re-running installer."
print_notification "We have to re-run the installer. The first run verifies you have the right pre-reqs available and installs them."
print_notification "This time, select option 4 to compile smbexec."
print_notification "Like all good things compiled from source, be patient; this'll take a moment or two."
read -p "Select option 5 to exit, post-compile, if prompted. Hit enter to continue" pause_2
bash install.sh
success_check
print_notification "smbexec should be installed wherever you told the installer script to install it to. That should be /opt/other-tools/smbexec-source"

########################################

print_status "all installations and updates complete."
print_status "Stand for something, because if you don't, you'll fall for anything."

########################################

exit 0