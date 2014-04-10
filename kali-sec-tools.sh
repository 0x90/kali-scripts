#!/bin/bash
# Kali Linux additional tools installation script
#
. helper.sh



android_tools(){
    if ask "Install tools for Andoid hacking?" Y; then
        apt-get install -y abootimg smali android-sdk apktool dex2jar

        #TODO: check if file exists
        add-apt-repository ppa:nilarimogard/webupd8
        apt-get update -y && apt-get install android-tools-adb android-tools-fastboot
    fi
}

ios_tools(){
    if ask "Install tools for iOS hacking?" Y; then
        apt-get install -y ifuse ipheth-utils iphone-backup-analyzer libimobiledevice-utils libimobiledevice2 python-imobiledevice usbmuxd
    fi
}

security_tools(){

    if ask "Do you want to install armitage, mimikatz, unicornscan, and zenmap.. ?" Y; then
        print_status "Installing armitage, mimikatz, unicornscan, and zenmap.."
        apt-get -y install armitage mimikatz unicornscan zenmap
        success_check

        #This is a simple git pull of the Cortana .cna script repository available on github.
        print_status "Grabbing Armitage Cortana Scripts via github.."
        git clone http://www.github.com/rsmudge/cortana-scripts.git /opt/cortana
        success_check
        print_notification "Cortana scripts installed under /opt/cortana."
    fi

    if ask "Do you want to install BeEF,arachni,w3af?" Y; then
        apt-get -y install beef-xss beef-xss-bundle arachni w3af
    fi

    if ask "Do you want to install Veil?" Y; then
        git clone git://github.com/ChrisTruncer/Veil.git /usr/share/veil/
    fi

    if ask  "Do you want to install OWASP tools? (zaproxy,mantra)" Y; then
        apt-get install -y zaproxy owasp-mantra-ff
    fi

    if ask "Do you want to install OWTF?" Y; then
        git clone https://github.com/7a/owtf/ /tmp/owtf
        python /tmp/owtf/install/install.py
#        cd /root
#        git clone https://github.com/7a/owtf/
#        cd owtf
#        python install/install.py
    fi

    # http://seclist.us/2013/12/update-watobo-v-0-9-13-semi-automated-web-application-security-audits.html
    if ask "Do you want to install WATOBO?" Y; then
        gem install watobo
    fi

    if ask "Do you want to install htshells?" Y; then
        git clone git://github.com/wireghoul/htshells.git /usr/share/htshells/
    fi

    if ask "Do you want to install the buffer-overvlow-kit? (requires ruby)" Y; then
        mkdir ~/develop
        cd ~/develop
        git clone https://github.com/KINGSABRI/BufferOverflow-Kit.git
    fi

    if ask "Do you want install mitm tools?" Y; then
        print_notification "Installing yamas.sh"
        apt-get install -y arpspoof ettercap-text-only sslstrip
        wget http://comax.fr/yamas/bt5/yamas.sh -O /usr/bin/yamas
        chmod +x /usr/bin/yamas

        print_notification "Installing parponera"
        git clone https://code.google.com/p/paraponera/ ~/develop/parponera
        cd ~/develop/parponera
        ./install.sh

        print_notification "Installing haxorblox"
        apt-get install -y hamster-sidejack ferret-sidejack dsniff gawk snarf ngrep
    fi

    if ask "Do you want to install TOR?" Y; then
        #TODO: add check if repo is already added
        echo "# tor repository" >> /etc/apt/sources.list
        echo "deb http://deb.torproject.org/torproject.org wheezy main" >> /etc/apt/sources.list

        gpg --keyserver keys.gnupg.net --recv 886DDD89
        gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | sudo apt-key add -
        apt-get update
        apt-get install -y deb.torproject.org-keyring tor tor-geoipdb polipo vidalia
        mv /etc/polipo/config /etc/polipo/config.orig
        wget https://gitweb.torproject.org/torbrowser.git/blob_plain/ae4aa49ad9100a50eec049d0a419fac63a84d874:/build-scripts/config/polipo.conf -O /etc/polipo/config
        service tor restart
        service polipo restart
        update-rc.d tor enable
        update-rc.d polipo enable
    fi

    if ask "Install SVN version of fuzzdb?" Y; then
        print_status "Installing SVN version of fuzzdb in /usr/share/fuzzdb and keeping it updated."
        if [ -d /usr/share/fuzzdb ]; then
            cd /usr/share/fuzzdb
            svn up
        else
            print_notification "Fuzzdb not found, installing at /usr/share/fuzzdb."
            cd /usr/share
            svn co http://fuzzdb.googlecode.com/svn/trunk fuzzdb
        fi
        print_good "Installed or updated Fuzzdb to /usr/share/fuzzdb."
    fi

    if ask "Install SVN version of nmap?" N; then
        print_status "Adding nmap-svn to /opt/nmap-svn."
        svn co --username guest --password "" https://svn.nmap.org/nmap /opt/nmap-svn
        cd /opt/nmap-svn
        ./configure && make
        /opt/nmap-svn/nmap -V
        print_good "Installed or updated nmap-svn to /opt/nmap-svn."
    fi

    if ask "Install SVN version of aircrack-ng?" N; then
        if [ -d /opt/aircrack-ng-svn ]; then
            cd /opt/aircrack-ng-svn
            svn up
        else
            svn co http://svn.aircrack-ng.org/trunk/ /opt/aircrack-ng-svn
            cd /opt/aircrack-ng-svn
        fi
        make && make install
        airodump-ng-oui-update
        print_good "Downloaded svn version of aircrack-ng to /opt/aircrack-ng-svn and overwrote package with it."
    fi

    if ask "Install freeradius server 2.1.11 with WPE patch?" N; then
        #Checking for free-radius and it not found installing it with the wpe patch.  This code is totally stollen from the easy-creds install file.  :-D
        if [ ! -e /usr/bin/radiusd ] && [ ! -e /usr/sbin/radiusd ] && [ ! -e /usr/local/sbin/radiusd ] && [ ! -e /usr/local/bin/radiusd ]; then
            print_notification "Free-radius is not installed, will attempt to install..."

            mkdir /tmp/freeradius
            print_notification "Downloading freeradius server 2.1.11 and the wpe patch..."
            wget ftp://ftp.freeradius.org/pub/radius/old/freeradius-server-2.1.11.tar.bz2 -O /tmp/freeradius/freeradius-server-2.1.11.tar.bz2
            wget http://www.opensecurityresearch.com/files/freeradius-wpe-2.1.11.patch -O /tmp/freeradius/freeradius-wpe-2.1.11.patch
            cd /tmp/freeradius
            tar -jxvf freeradius-server-2.1.11.tar.bz2
            mv freeradius-wpe-2.1.11.patch /tmp/ec-install/freeradius-server-2.1.11/freeradius-wpe-2.1.11.patch
            cd freeradius-server-2.1.11
            patch -p1 < freeradius-wpe-2.1.11.patch
            print_notification "Installing the patched freeradius server..."

            ./configure && make && make install
            cd /usr/local/etc/raddb/certs/
            ./bootstrap
            rm -r /tmp/freeradius
            print_good "The patched freeradius server has been installed"
        else
            print_good "I found free-radius installed on your system"
        fi
    fi

    if ask "Install easy-creds?" Y; then
        #Installing easy-creds.  The needed packages should be taken care of in the extra packages section.
        if [ -d /opt/easy-creds ]; then
            echo "Easy easy-creds install already found."
        else
            git clone git://github.com/brav0hax/easy-creds.git /opt/easy-creds
            ln -s /opt/easy-creds/easy-creds.sh /usr/bin/easy-creds
        fi
        updatedb
        echo -e "If easy-creds was not found it was installed."
    fi

    #TODO: add Nessus installation
    if ask "Install unsploitable?" N; then
        print_status "Pulling Unsploitable.."
        mkdir /opt/other-tools
        cd /opt/other-tools
        svn checkout svn://svn.code.sf.net/p/unsploitable/code/trunk unsploitable
        success_check
        print_notification "Unsploitable installed to /opt/other-tools/unsploitable"
    fi

    if ask "Pulling DTFTB (Defense Tools for the Blind)?" N; then
        print_status "The DTFTB scripts are a set of tools that are CTF oriented."
        svn checkout svn://svn.code.sf.net/p/dtftb/code/trunk dtftb
        success_check
        print_notification "DTFTB installed to /opt/other-tools/dtftb"
    fi

    if ask "Do you want to install stand-alone smbexec tool from brav0hax's github. (180mb of data)" N; then
        print_status "Pulling SMBexec. It's going to take a bit of time."
        git clone https://github.com/brav0hax/smbexec.git /opt/other-tools/smbexec-source
        success_check
        cd /opt/other-tools/smbexec-source

        #The script has to be ran twice. The first time, the script grabs the prereqs, etc required to compile smbexec
        print_status "Performing Installation pre-reqs."
        print_notification "The installation is scripted. When prompted for what OS you are using choose Debian or Ubuntu variant."
        print_notification "When prompted for where to install smbexec, select /opt/other-tools/smbexec-source"
        print_notification "Select option 5 to exit, if prompted."
        read -p "You'll have to run the installer twice. The script immediately bails after installing pre-reqs. Hit enter to continue." pause
        bash install.sh
        success_check

        #The second time around, it compiles smbexec, actually installing it.
        print_status "Re-running installer."
        print_notification "We have to re-run the installer. The first run verifies you have the right pre-reqs available and installs them."
        print_notification "This time, select option 4 to compile smbexec."
        print_notification "Like all good things compiled from source, be patient; this'll take a moment or two."
        read -p "Select option 5 to exit, post-compile, if prompted. Hit enter to continue" pause
        bash install.sh
        success_check
        print_notification "smbexec should be installed wherever you told the installer script to install it to. That should be /opt/other-tools/smbexec-source"
    fi

    if ask "Install Kali Lazy?" Y; then
        #TODO: check if wget installed
        wget -q http://yourgeekonthego.com/scripts/lazykali/lazykali.sh -O /usr/bin/lazykali
        chmod +x /usr/bin/lazykali
        lazykali

#        curl https://lazykali.googlecode.com/git/lazykali.sh > /usr/bin/lazykali
#        lazykali
#        cd /root
#        git clone https://code.google.com/p/lazykali/
#        lazykali/lazykali.sh
    fi
}

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


check_euid
update
security_tools