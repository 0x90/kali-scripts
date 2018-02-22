# kali-scripts reborn to Makefile
# author: @090h
#
PROJECT := kali-scripts
CC      := gcc
EUID    := $(shell id -u -r)
DESTDIR ?=/usr
PREFIX ?= $(DESTDIR)
TMPDIR=/tmp/kali-scripts
CRDADIR=/lib/crda
CRDADB=${CRDADIR}/regulatory.bin
TOP ?= $(shell pwd)
THIS := ${TOP}/Makefile
ROOT_DIR := ${CURDIR}
MODWIFI_RELEASE=modwifi-4.7.4-experimental-1.tar.gz
MODWIFI_URL=https://github.com/vanhoefm/modwifi/raw/master/releases/${MODWIFI_RELEASE}
.DEFAULT_GOAL := help
.PHONY: help clean archivers 32bit common-tools deps wifi wireless-db reaver dev-ide

# Macros
.CLEAR=\x1b[0m
.BOLD=\x1b[01m
.RED=\x1b[31;01m
.GREEN=\x1b[32;01m
.YELLOW=\x1b[33;01m

# Check for root
check:
ifneq ($(EUID),0)
	@echo "Please run as root user"
	@exit 1
endif

# Re-usable target for yes no prompt. Usage: make .prompt-yesno message="Is it yes or no?"
# Will exit with error if not yes
.prompt-yesno2:
	@exec 9<&0 0</dev/tty
	echo "$(message) [Y]:"
	[[ -z $$FOUNDATION_NO_WAIT ]] && read -rs -t5 -n 1 yn;
	exec 0<&9 9<&-
	[[ -z $$yn ]] || [[ $$yn == [yY] ]] && echo Y >&2 || (echo N >&2 && exit 1)

# Re-usable target for yes no prompt. Usage: make .prompt-yesno message="Is it yes or no?"
# Will exit with error if not yes
.prompt-yesno:
	@exec 8<&0 0</dev/tty
	@case "$(shell [[ ! -z $$FOUNDATION_NO_WAIT ]] && echo "Y" \
	        || (read -t5 -n1 -p "    > $(message) [Y]:" && echo $$REPLY))" in \
	   [nN]) echo -e "\n    > $(.YELLOW)[ABORTED]$(.CLEAR)" && exit 1 ;; \
  esac && echo -e ""
	([[ ! -z $$FOUNDATION_NO_WAIT ]] && \
		echo -e "    > $(.GREEN)[AUTO CONTINUING]$(.CLEAR)" || \
		echo -e "    > $(.GREEN)[CONTINUING]$(.CLEAR)")

define gitclone
	$(eval repo := $(TMPDIR)/$(shell basename $(1)))
	@if [ ! -d $(repo) ]; then git clone --recursive $(1) $(repo); fi;
endef


default: help;

##: list - list available make targets
list:
	@grep -v "#" Makefile|grep '^[^#.]*:$$'  | awk -F: '{ print $$1 }'

#: help - display callable targets                              *
help:
	@echo "\n\t`printf "\033[32m"`\t     .:[Kali Scripts reb0rn to Makefile]:.`printf "\033[0m"`"
	@echo "\t+---------------------------------------------------------------+"
	@egrep -o "^#: (.+)" [Mm]akefile  |sort| sed "s/#: /	*  `printf "\033[32m"`/"| sed "s/ - /`printf "\033[0m"` - /"
	@echo "\t+---------------------------------------------------------------+"
	@echo "\t\t`printf "\033[32m"`      greetz fly to all DC7499 community`printf "\033[0m"`"
	@echo "\t\t`printf "\033[32m"`           ~~-<  @090h 2018  >-~~`printf "\033[0m"`\n"

#: clean - cleanup source code and unused packages              *
clean:
	@echo "Cleaning packages"
	apt-get -y autoremove && apt-get -y clean
	@echo "Cleaning temp directory: $(TMPDIR)"
	@rm -rf $(TMPDIR)

#: fresh - update kali-scripts repo                             *
fresh:
	git pull

#: upgrade - update and upgrade current system                  *
upgrade:
	apt-get update && apt-get upgrade -y

#: kali - install Kali Linux repos and soft                     *
kali:
	echo "deb http://http.kali.org/kali kali-rolling main contrib non-free" > /etc/apt/sources.list
	echo "deb-src http://http.kali.org/kali kali-rolling main contrib non-free" > /etc/apt/sources.list
	sudo apt-get update -y
	sudo apt-get install kali-archive-keyring -y
	sudo apt-get update -y
	sudo apt-get -y install kali-linux-wireless kali-linux-sdr

##: archivers - install archivers
archivers:
	@echo "installing archivers.."
	@apt-get -y install gzip bzip2 tar lzma arj lhasa p7zip-full cabextract unace unrar zip unzip \
	sharutils uudeview mpack cabextract file-roller zlib1g zlib1g-dev liblzma-dev liblzo2-dev

##: 32bit - install 32 bit tools and libraries
32bit:
	@if [ `getconf LONG_BIT` != "64" ] ; then exit 1; fi
	@echo "64-bit OS detected. installing 32-bit libs..."
	dpkg --add-architecture i386
	apt-get update -y && apt-get install -y libstdc++6:i386 libgcc1:i386 zlib1g:i386 libncurses5:i386

##: common - install common tools
common:
	@echo "installing common tools.."
	apt-get install -y terminator tmux htop iftop iotop mc screen curl wget
################################# deps #########################################

################################# ssh ##########################################
##: sshd - Configure SSHD                                       *
sshd:
	@echo "Configuring SSHD"
	make .prompt-yesno message="Enable root login via SSHD with password?" && make sshd-root
	make .prompt-yesno message="Do you want to install fresh sshd/ssh keys?" && make sshd-keys
	systemctl restart ssh

##: sshd-root - Enable root login via SSHD with password auth
sshd-root:
	@echo "Enabling root login with password"
	sed -i 's/prohibit-password/yes/' /etc/ssh/sshd_config && systemctl restart ssh

##: sshd-keys - Regenerate SSH keys
sshd-keys:
	@echo "Removing old host keys.."
	rm -rf /etc/ssh/ssh_host_*
	@echo "Regenerating host keys.."
	dpkg-reconfigure openssh-server
	mkdir /etc/ssh/default_kali_keys && mv /etc/ssh/ssh_host* /etc/ssh/default_kali_keys/
	dpkg-reconfigure openssh-server
	@echo "please make sure that those keys differ"
	md5sum /etc/ssh/default_kali_keys/*
	md5sum /etc/ssh/ssh_host*
	service ssh try-restart
	ssh-keygen -t rsa -b 2048
################################# ssh ##########################################

################################# dev ##########################################
##: dev-vcs - instal VCS (git, hg,cvs)
dev-vcs:
	@echo "Installing VCS (git, hg,cvs)"
	@apt-get install -y git subversion mercurial

##: dev-build - install build tools and environment
dev-build:
	@echo "Istalling development tools and environment"
	@apt-get install -y cmake cmake-data module-assistant build-essential patch g++ gcc gcc-multilib \
	dkms patchutils strace wdiff pkg-config automake autoconf flex bison gawk flex gettext \
	linux-source libncurses5-dev libreadline6 libreadline6-dev \
	libbz2-dev zlib1g-dev fakeroot ncurses-dev libtool libmagickcore-dev libmagick++-dev libmagickwand-dev \
	libyaml-dev libxslt1-dev libxml2-dev libxslt-dev libc6-dev python-pip libsqlite3-dev sqlite3
	# linux-headers-`uname -r`

##: dev-crypto - install crypto libraries
dev-crypto:
	@echo "installing crypto libs"
	@apt-get install -y openssl libssl-dev python-m2crypto libgcrypt20 libgcrypt20-dev cracklib-runtime

##: dev-ide - install IDE (Atom,PyCharm, etc)
dev-ide:
	@echo "installing Atom IDE"
	curl -L https://packagecloud.io/AtomEditor/atom/gpgkey | sudo apt-key add -
	echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" > /etc/apt/sources.list.d/atom.list
	apt-get update &&  apt-get install -y atom

##: dev-network - install different network libraries                        *
dev-network:
	@echo "installing network libs"
	@apt-get install -y libpcap-dev libpcap0.8 libpcap0.8-dev libdnet \
	libnetfilter-queue-dev libnl-genl-3-dev libssh2-1-dev

##: dev-android - install Android SDK/NDK and other tools                    *
dev-android: dev-java deps
	@echo "Installing Android Studio dependencies (ADB, KVM, QEMU)"
	sudo apt install -y gcc-multilib g++-multilib libc6-dev-i386 qemu-kvm mesa-utils adb
	@echo "Adding Android Studio repository"
	@echo "deb http://ppa.launchpad.net/maarten-fonville/android-studio/ubuntu trusty main" > /etc/apt/sources.list.d/android.list
	@echo "Adding Android Studio key: 4DEA8909DC6A13A3"
	apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv-keys 4DEA8909DC6A13A3
	apt-get update && apt -y install android-studio netbeans-installer

##: dev-crossdev - install cross platfrorm dev tools
dev-crossdev:	deps
	# http://www.emdebian.org/crosstools.html
	@echo "installing Emdebian, xapt"
	apt-get install emdebian-archive-keyring xapt -y
	# sudo apt-get install gcc-msp430 binutils-msp430 msp430-libc msp430mcu mspdebug
	# apt_add_source emdebian
	# cp -f "files/etc/emdebian.list" /etc/apt/sources.list.d/emdebian.list && apt-get update -y
	echo "deb http://ftp.us.debian.org/debian/ squeeze main" > /etc/apt/sources.list.d/emdebian.list
	echo "deb http://www.emdebian.org/debian/ squeeze main" >> /etc/apt/sources.list.d/emdebian.list
	echo "deb http://www.emdebian.org/debian/ oldstable main" >> /etc/apt/sources.list/emdebian.list
	apt-get update -y
	@echo "installing GCC-4.4 for mips, mipsel"
	apt-get install -y linux-libc-dev-mipsel-cross libc6-mipsel-cross libc6-dev-mipsel-cross \
	binutils-mipsel-linux-gnu gcc-4.4-mipsel-linux-gnu g++-4.4-mipsel-linux-gnu
	apt-get install -y linux-libc-dev-mips-cross libc6-mips-cross libc6-dev-mips-cross \
	binutils-mips-linux-gnu gcc-4.4-mips-linux-gnu g++-4.4-mips-linux-gnu -y

##: dev-python - install python developer environment            *
dev-python:	dev-vcs dev-db
	@echo "installing pyenv, pip and other python modules"
	apt-get install -y python-dev bpython python-pip python-twisted python-shodan  \
	python-virtualenv python-pygments python-tornado python-sqlalchemy python-lxml python-pymongo \
	python-gnuplot python-matplotlib python-scipy python-requests python-gevent \
	python-numpy python-gi-dev python-psycopg2 swig doxygen python-lzma python3 python3-pip \
	python-opengl python-qt4 python-qt4-gl libqt4-opengl python-pyqtgraph python-pyside \
	python-pip python-dev cython
	pip install cookiecutter
	@if [ ! -d ~/.pyenv ]; then \
		curl -L https://raw.githubusercontent.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash ; \
	else \
		echo "PyEnv already installed"; \
	fi;

##: dev-java - install Oracle Java       *
dev-java:
	@echo "installing webupd8team repo..."
	@echo "deb http://ppa.launchpad.net/webupd8team/java/ubuntu trusty main" >> /etc/apt/sources.list.d/java.list
	@echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu precise main" >> /etc/apt/sources.list.d/java.list
	@echo "adding webupd8team key EEA14886"
	@apt-key adv --keyserver keyserver.ubuntu.com --recv-keys EEA14886
	@apt-get update && apt-get install -y oracle-java8-installer oracle-java8-set-default
	source /etc/profile
################################# dev ##########################################

################################# regdb ########################################
#: wifi-regdb - install wireles-regdb with unlocked freq/amp    *
wifi-regdb: wifi-common
	@echo "Cloning repos wireless-db repos."
	$(call gitclone,https://github.com/0x90/crda-ct)
	$(call gitclone,https://github.com/0x90/wireless-regdb)
	@echo "Building and installing deps for building wireless-db"
	$(MAKE) -C $(repo) && install ${TMPDIR}/wireless-regdb/regulatory.bin ${CRDADB}
	@echo "Copying certs.."
	install ${TMPDIR}/wireless-regdb/root.key.pub.pem ${TMPDIR}/crda-ct/pubkeys/
	install ${CRDADIR}/pubkeys/benh@debian.org.key.pub.pem ${TMPDIR}/crda-ct/pubkeys/
	@echo "Building and installing CRDA"
	cd ${TMPDIR}/crda-ct && export REG_BIN=${CRDADB} && make && make install

# TODO: check and add
wifi-frequency-hacker:
	git clone https://github.com/singe/wifi-frequency-hacker ${TMPDIR}/wifi-frequency-hacker
	cp /lib/crda/regulatory.bin /lib/crda/regulatory.bin.orig
	install ${TMPDIR}/wifi-frequency-hacker/regulatory.bin /lib/crda/
	install ${TMPDIR}/wifi-frequency-hacker/singe.key.pub.pem /lib/crda/pubkeys/
################################# regdb ########################################

################################# libs #########################################

##: lorcon - install Lorcon library with python bindings         *
lorcon:
	$(call gitclone,https://github.com/0x90/lorcon)
	@echo "installing Lorcon from $(repo)"
	@cd $(repo) && ./configure --prefix=$(PREFIX) && make && make install
	@echo "installing pylorcon2 bindings"
	@cd $(repo)/pylorcon2 && python setup.py build && python setup.py install

##: libuwifi - WiFi lib with injection/monitor/channel support   *
libuwifi:
	$(call gitclone,https://github.com/br101/libuwifi)
	@echo "installing Lorcon from $(repo)"
	@cd $(repo) && ./configure --prefix=$(PREFIX) && make && make install

##: libtins - WiFi lib with injection/monitor/channel support   *
libtins:
	$(call gitclone,https://github.com/mfontanini/libtins.git)
	mkdir $(repo)/build && cd $(repo)/build
	cmake ../ -DLIBTINS_ENABLE_CXX11=1 && make && make install

#: wifi-python - install python libraries for WiFi              *
python-wifi:
	@echo "Installing python network libs.."
	pip install wifi scapy==2.3.2 impacket pcapy pcappy
	@echo "Installing pythonwifi library"
	pip install "git+https://github.com/pingflood/pythonwifi.git"
	@echo "Installling PyRIC (new Lorcon)"
	pip install "git+https://github.com/wraith-wireless/PyRIC#egg=PyRIC"
	# @echo "Installling cycapture for libpcap+libtins bindings"
	# pip install "git+https://github.com/stephane-martin/cycapture#egg=cycapture"
	# @if [ ! -d ${TMPDIR}/cycapture ]; then \
		# @echo "Downloading cycapture"; \
		# git clone --recursive https://github.com/stephane-martin/cycapture ${TMPDIR}/cycapture;\
	# fi;
	# ${TMPDIR}/cycapture/setup.py install
	@echo "Installing itame for dealing with MPDU/MSDU frames"
	apt install libtins-dev libboost-dev -y
	pip install itamae
	# @echo "Installing pytins..."
	# $(call gitclone,https://github.com/mfontanini/pytins)
	# cd $(repo) && make && make install
	@echo "Installing py80211"
	pip install "git+https://github.com/0x90/py80211#egg=py80211"

	# https://github.com/wraith-wireless/wraith
	# https://github.com/bcopeland/python-radiotap
	# https://github.com/weaknetlabs/libpcap-80211-c
	# https://github.com/0x90/wifi-arsenal/tree/master/libmoep-1.1
	# https://github.com/moepinet/moepdefend
################################# libs ########################################

################################ deauth #######################################
wifijammer:
	@echo "Installing mdk3"
	apt-get install -y mdk3
	@echo "Installing wifijammer"
	pip install "git+https://github.com/0x90/wifijammer#egg=wifijammer"
	# pip install git+https://github.com/llazzaro/wifijammer.git

zizzania:
	@echo "Installing zizzania dependencies"
	apt-get install -y scons libpcap-dev uthash-dev
	@echo "Installing zizzania"
	$(call gitclone,https://github.com/cyrus-and/zizzania)
	cd $(repo) && make && make install
################################ deauth #######################################

################################## WPA ########################################
##: wifi-common - install common WiFi hacking tools
wifi-common:
	@echo "installing WiFi tools and dependecies"
	apt-get install -y kismet kismet-plugins giskismet mdk3 linssid \
	wavemon rfkill iw tshark fern-wifi-cracker wifite

horst:
	sudo apt-get install libncurses5-dev libnl-3-dev libnl-genl-3-dev
	git clone --recursive https://github.com/br101/horst ${TMPDIR}/horst

##: aircrack - install EXPERIMENTAL build of aircrack-ng     *
aircrack:
	@echo "Installing aircrack-ng from source..."
	apt-get install	-y libgcrypt20-dev
	$(call gitclone,https://github.com/aircrack-ng/aircrack-ng)
	cd $(repo) && make sqlite=true experimental=true ext_scripts=true pcre=true gcrypt=true libnl=true
	cd $(repo) && make strip && make install

##: airoscript - install airoscript                            *
airoscript:
	@echo "Installing airoscript-ng from source..."
	svn co http://svn.aircrack-ng.org/branch/airoscript-ng/ ${TMPDIR}/airoscript-ng
	cd ${TMPDIR}/airoscript-ng && make install

##: airgraph - install airgraph tool                            *
airgraph:
	@echo "Installing airgraph-ng from source..."
	svn co http://svn.aircrack-ng.org/trunk/scripts/airgraph-ng ${TMPDIR}/airgraph-ng
	cd ${TMPDIR}/airgraph-ng && make install

##: handshaker - install tool for easy handshake capture         *
handshaker:	deps reaver pixiewps
	apt-get install -y beep bc
	$(call gitclone,https://github.com/d4rkcat/HandShaker)
	cd $(repo) && make install

##: pyrit - install latest version of Pyrit from sources         *
pyrit:	deps
	# NB: Updating from 2.3.2 to 2.3.3 breaks pyrit
	# https://github.com/JPaulMora/Pyrit/issues/500
	pip install scapy==2.3.2
	# apt-get install pyrit
	@echo "installing Pyrit from source"
	$(call gitclone,https://github.com/JPaulMora/Pyrit)
	cd $(repo) && python setup.py clean && python setup.py build && python setup.py install

brute-common:
	@echo "Installing common bruteforce tools for WiFi"
	apt-get install -y hashcat cowpatty john

##: airhammer - WPA-Enterprise horizontal brute-force tool       *
air-hammer:
	@echo "Installing Air-Hammer - A WPA Enterprise horizontal brute-force attack tool"
	# TODO: https://github.com/Wh1t3Rh1n0/air-hammer

##: wpa-bruteforcer - WPA brute-force for AP without clients     *
wpa-bruteforcer:
	# TODO: https://github.com/SYWorks/wpa-bruteforcer
	pip install "git+https://github.com/0x90/wpa-bruteforcer#egg=wpa-bruteforcer"

##: wordlist
wordlist:
	@echo "Installing standard wordlists"
	apt-get install -y wordlists
	cd /usr/share/wordlists/ && gunzip rockyou.txt.gz
	@echo "Downloading wordlists for WPA/WPA2 brute"
	git clone https://github.com/kennyn510/wpa2-wordlists /usr/share/wordlists/wpa2-wordlists
################################## WPA ########################################

################################## WPS ########################################
##: reaver - install fresh version of reaver-wps-fork-t6x        *
reaver:
	# @if [ -e /usr/bin/reaver ]; then \
	# 	@echo "Trying to remove original reaver-wps"; \
	# 	sudo dpkg -r --force-depends reaver; \
	# fi;
	@echo "Installing reaver-wps-fork-t6x from github"
	$(call gitclone,https://github.com/t6x/reaver-wps-fork-t6x)
	cd $(repo)/src/ && ./configure --prefix=$(PREFIX) && make && make install

##: reaver-spoof - install reaver-spoof with MAC spoof support   *
reaver-spoof:
	$(call gitclone,https://github.com/gabrielrcouto/reaver-wps)
	# cd $(repo)/src/ && ./configure --prefix=$(PREFIX) && make && make install
	cd $(repo)/src/ && ./configure && make && make install
	mv /usr/local/bin/reaver /usr/local/bin/reaver-spoof

##: pixiewps - install fresh pixiewps from Github                *
pixiewps:
	@echo "Trying to remove original pixiewps"
	# sudo dpkg -r --force-depends pixiewps
	$(call gitclone,https://github.com/wiire/pixiewps)
	cd $(repo)/src/ && make && make install

##: penetrator - install penetrator from source                  *
penetrator:
	$(call gitclone,https://github.com/xXx-stalin-666-money-xXx/penetrator-wps)
	cd $(repo) && ./install.sh;

##: wpsik - install wpsik - WPS info gathering tool              *
wpsik:
	@echo "Installling wpsik"
	pip install "git+https://github.com/0x90/wpsik#egg=wpsik"

##TODO: add bully
################################# WPS ##########################################

############################### autopwn ########################################
##: wifite - install correct version of wifite                   *
wifite: deps reaver pixiewps
	$(call gitclone,https://github.com/derv82/wifite)
	install -m 755 $(repo)/wifite.py /usr/bin/wifite-old
	$(call gitclone,https://github.com/aanarchyy/wifite-mod-pixiewps)
	install -m 755 $(repo)/wifite-ng /usr/bin/wifite-ng

##: autopixiewps - install autopwner script for pixiewps         *
autopixiewps:
	 pip install "git+https://github.com/0x90/AutoPixieWps#egg=AutoPixieWps"

##: autoreaver - install autoreaver                              *
autoreaver:
	apt-get install -y lshw
	@if [ ! -d /usr/share/auto-reaver ]; then \
		git clone https://github.com/DominikStyp/auto-reaver /usr/share/auto-reaver \
	fi;

wpsbreak:
	@if [ ! -d /usr/share/HT_WPS-Break ]; then \
		git clone https://github.com/radi944/HT_WPS-Break /usr/share/HT_WPS-Break \
	fi;

autowps:
	@if [ ! -d /usr/share/wifiAutoWPS ]; then \
		git clone https://github.com/arnaucode/wifiAutoWPS /usr/share/wifiAutoWPS \
	fi;

airgeddon:	deps reaver pixiewps
	apt-get install -y crunch isc-dhcp-server sslstrip lighttpd
	git clone https://github.com/v1s1t0r1sh3r3/airgeddon.git /usr/share/airgeddon
	chmod +x /usr/share/airgeddon/airgeddon.sh
	ln -s /usr/share/airgeddon/airgeddon.sh /usr/bin/airgeddon

fluxion:
	@echo "Installing fluxion dependencies"
	sudo apt-get install -y isc-dhcp-server lighttpd macchanger php-cgi hostapd bully rfkill \
	zenity psmisc gawk curl nmap php-cgi lua-lpeg
	$(call gitclone,https://github.com/deltaxflux/fluxion)
	cd $(repo) && ./Installer.sh

atear:
	@echo "Installing AtEar dependencies"
	apt-get install -y aircrack-ng tshark hostapd python-dev python-flask python-paramiko \
	python-psycopg2 python-pyodbc python-sqlite
	git clone https://github.com/NORMA-Inc/AtEar.git /usr/share/AtEar/
	cd /usr/share/AtEar/install.sh && sudo chmod +x install.sh && sudo ./install.sh

# TODO: Add soft
# https://github.com/derv82/wifite2
# https://github.com/esc0rtd3w/wifi-hacker
# https://github.com/vnik5287/wpa-autopwn
# https://github.com/adelashraf/cenarius
# https://github.com/esc0rtd3w/wifi-hacker
# https://github.com/vnik5287/wpa-autopwn
# https://github.com/adelashraf/cenarius
################################ all in one  ###################################

################################### recon  #####################################
##: wifi-recon - install tools fot WiFi reconnaissance          *
wifi-recon:
	@echo "Installing WRAITH: Wireless Reconnaissance And Intelligent Target Harvesting"
	pip install 'git+https://github.com/wraith-wireless/wraith#egg=wraith'
	# https://github.com/blaa/WifiStalker
	@echo "Installing WIG"
	pip install pcapy impacket
	# https://github.com/6e726d/WIG
	@echo "Installing Snoopy-NG"
	# https://github.com/sensepost/snoopy-ng
	@echo "Installing wifi-radar"
	# pip install scapy netaddr git+https://github.com/pingflood/pythonwifi.git
	# https://github.com/stef/wireless-radar
	pip install wireless-radar
	setcap 'CAP_NET_RAW+eip CAP_NET_ADMIN+eip' /usr/bin/python2.7

##: wifi-ids - install IDS/IPS for WiFi                         *
wifi-ids:
	@echo "Installing WAIDPS"
	pip install "git+https://github.com/0x90/waidps#egg=waidps"
	# pip install pycrypto
	# https://github.com/SYWorks/waidps
	@echo "Installing wireless-ids"
	# https://github.com/SYWorks/wireless-ids
	@echo "Installing WiWo"
	# https://github.com/CoreSecurity/wiwo
################################### recon  #####################################

################################## hotspot #####################################
##: hotspotd - install hotspotd for easy AP configuration        *
hotspotd:
	@echo "Installing hotspotd.."
	$(call gitclone,https://github.com/0x90/hotspotd)
	cd $(repo) && sudo python2 setup.py install
	# https://github.com/oblique/create_ap

wifipumpkin:
	git clone https://github.com/P0cL4bs/WiFi-Pumpkin.git ${TMPDIR}/WiFi-Pumpkin
	cd ${TMPDIR}/WiFi-Pumpkin && chmod +x installer.sh && ./installer.sh --install

createap:
	@echo "Installing create_ap.."
	$(call gitclone,https://github.com/oblique/create_ap)
	cd $(repo)/create_ap && sudo make install

linset:
	apt-get install -y isc-dhcp-server lighttpd macchanger php5-cgi macchanger-gtk hostapd
	git clone https://github.com/vk496/linset
	cd linset && chmod +x linset && ./linset

rogueap-deps:
	apt-get install -y dnsmasq cupid-wpasupplicant hostapd mana-toolkit cupid-hostapd freeradius-wpe hostapd-wpe

## TODO: add soft
# https://github.com/wouter-glasswall/rogueap
# https://github.com/xdavidhu/mitmAP
# https://github.com/entropy1337/infernal-twin
# https://github.com/Nick-the-Greek/Aerial
# https://github.com/zackiles/Rspoof
# https://github.com/baggybin/LokiPi
################################## RogueAP #####################################

################################# Spectral #####################################
##: wireless-spectral - install spectral scan tools             *
speccy:
	git clone https://github.com/bcopeland/speccy ${TMPDIR}/speccy

ath9k-spectral-scan:
	git clone https://github.com/kazikcz/ath9k-spectral-scan ${TMPDIR}/ath9k-spectral-scan
	# TODO: https://github.com/terbo/sigmon
	# TODO: https://github.com/s7jones/Wifi-Signal-Plotter
################################# Spectral #####################################

################################## Kernel ######################################
##: wifi-kernel - install EXPERIMENTAL kernel for 80211 debug         *
wifi-kernel:
	@echo "Installing kernel source dependencies"
	@if [ ! -d /usr/src/linux-source-4.8 ]; then \
		@echo "Unpacking kernel"; \
		cd /usr/src/ && unxz linux-source-4.8.tar.xz && tar xvf linux-source-4.8.tar;\
	fi;
	@echo "Configuring kernel.."
	cp /boot/config-4.8.0-kali1-amd64 /usr/src/linux-source-4.8/.config
	scripts/config --disable CC_STACKPROTECTOR_STRONG
	@echo "Applying kernel patches"
	# http://kernel.ubuntu.com/~kernel-ppa/mainline/v4.8-rc2/0002-UBUNTU-SAUCE-no-up-disable-pie-when-gcc-has-it-enabl.patch
	patch -p1 -d /usr/src/linux-source-4.8 < patches/0002-UBUNTU-SAUCE-no-up-disable-pie-when-gcc-has-it-enabl.patch
	@echo "Building kernel package"
	export CONCURRENCY_LEVEL=$(cat /proc/cpuinfo | grep processor | wc -l)
	make-kpkg clean
	fakeroot make-kpkg kernel_image

	@echo "Install the Modified Kernel"
	dpkg -i ../linux-image-3.14.5_3.14.5-10.00.Custom_amd64.deb
	update-initramfs -c -k 3.14.5
	update-grub2
################################## Kernel #####################################

################################## ModWiFi ####################################
modwifi-dependencies:
	@echo "Installing modwifi dependencies"
	# apt-get install -y g++ libssl-dev libnl-3-dev libnl-genl-3-dev
	apt-get install -y kernel-package ncurses-dev fakeroot linux-source
	@echo "Downloading modwifi: %{MODWIFI_RELEASE}"
	@if [ ! -d ${TMPDIR}/modwifi ]; then \
		mkdir -p ${TMPDIR}/modwifi ; \
		cd ${TMPDIR}/modwifi && wget ${MODWIFI_URL} && tar -xzf modwifi-*.tar.gz ; \
	else \
		echo "Found downloaded modwifi release."; \
	fi;

modwifi-kernel:
	@echo "Installing modwifi kernel"
	git clone -b research https://github.com/vanhoefm/ ${TMPDIR}/modwifi/linux
	cd ${TMPDIR}/modwifi/linux && make && make install

modwifi-ath9k:
	@echo "Installing modwifi tools"
	git clone -b research https://github.com/vanhoefm/modwifi-ath9k-htc ${TMPDIR}/modwifi/ath9k-htc
	cd ${TMPDIR}/modwifi/ath9k-htc && make && make install

modwifi-backports:
	@echo "Installing modwifi backports dependencies"
	apt-get install coccinelle splatch
	@echo "Installing modwifi backports"
	git clone -b research https://github.com/vanhoefm/modwifi-backports ${TMPDIR}/modwifi/backports
	cd ${TMPDIR}/modwifi/backports && make && make install

modwifi-drivers:
	@echo "Installing modwifi drivers..."
	cd ${TMPDIR}/modwifi/drivers && make defconfig-ath9k-debug && make && make install

modwifi-firmware:
	@echo "Backuping ath9k_htc firmware..."
	cp /lib/firmware/ath9k_htc/htc_7010-1.4.0.fw /lib/firmware/ath9k_htc/htc_7010-1.4.0.fw.bak
	cp /lib/firmware/ath9k_htc/htc_9271-1.4.0.fw /lib/firmware/ath9k_htc/htc_9271-1.4.0.fw.bak
	@echo "Installing modwifi firmware..."
	cp ${TMPDIR}/modwifi/target_firmware/htc_7010.fw /lib/firmware/ath9k_htc/htc_7010-1.4.0.fw
	cp ${TMPDIR}/modwifi/target_firmware/htc_9271.fw /lib/firmware/ath9k_htc/htc_9271-1.4.0.fw

modwifi-tools:
	@echo "Installing modwifi tools"
	apt-get install -y g++ libssl-dev libnl-3-dev libnl-genl-3-dev
	git clone -b master https://github.com/vanhoefm/modwifi-tools ${TMPDIR}/modwifi/tools
	mkdir -p ${TMPDIR}/modwifi/tools/build
	cd ${TMPDIR}/modwifi/tools/build && cmake .. && make all
	install ${TMPDIR}/modwifi/tools/build/channelmitm /usr/bin
	install ${TMPDIR}/modwifi/tools/build/constantjam /usr/bin
	install ${TMPDIR}/modwifi/tools/build/fastreply /usr/bin
	install ${TMPDIR}/modwifi/tools/build/reactivejam /usr/bin
################################## modwifi ######################################

################################ bluetooth #####################################
##: bluetooth - install bluetooth hacking tools                  *
bluetooth:
	@echo "installing deps for bluetooth hacking"
	apt-get install -y anyremote redfang spooftooph python-bluez obexfs bluewho btscanner \
	bluelog libbluetooth-dev spectools libncurses-dev libpcre3-dev spooftooph sakis3g ubertooth \
	gpsd  bluesnarfer bluez-tools bluewho wireshark wireshark-dev libwireshark-dev
	# TODO: add check for x86_x64
	# apt-get install -y libopenobex1:i386 libopenobex1-dev:i386 libbluetooth-dev:i386
################################ Bluetooth #####################################

################################## subghz ######################################
##: subghz - install tools for sughz bands: 433/866/915Mhz       *
subghz:
	@echo "installing ISM dependencies"
	apt-get install -y sdcc binutils make
	@echo "installing ISM hacking tools for 433/866/915Mhz"
	apt-get install rfcat libusb-1.0-0 python-usb
################################## subghz ######################################

################################## nrf24 ######################################
nrf24-deps:
	@echo "Cloning NRF24 arsenal"
	$(call gitclone,https://github.com/0x90/nrf24-arsenal)
	@echo "installing NRF24 dependencies"
	apt-get install -y sdcc binutils
	pip install -U pip
	pip install -U -I pyusb
	pip install -U platformio
	# pio platform install timsp430 teensy  windows_x86 nxplpc espressif32 linux_arm ststm32 microchippic32

nrf24-firmware:
	# https://github.com/BastilleResearch/nrf-research-firmware
	@echo "Build research firmware for nRF24LU1+"
	$(MAKE) -C ${TMPDIR}/nrf24-arsenal/mousejack/nrf-research-firmware
	@echo "Build firmware for Crazyradio"
	$(MAKE) -C ${TMPDIR}/nrf24-arsenal/crazyradio-firmware
	# TODO: add support for Crazyradio PA via make CRPA=1
	# @echo "Use make nrf24-flash-research to flash proper firmware"

## Flashing the Firmware
nrf24-flash:
	@if $(MAKE) -s -f $(THIS) .prompt-yesno message="Do you want to flash Research firmware over USB? "; then \
	  $(MAKE) -C ${TMPDIR}/nrf24-arsenal/mousejack/nrf-research-firmware install; \
	fi;
	@if make .prompt-yesno message="Do you want to flash Crazyradio firmware over USB? "; then \
	  cd ${TMPDIR}/nrf24-arsenal/crazyradio-firmware/usbtools ; \
		python ../usbtools/launchBootloader.py; \
		python ../usbtools/nrfbootload.py flash bin/cradio.bin; \
	fi;

nrf24-flash-research:
	$(MAKE) -C ${TMPDIR}/nrf24-arsenal/mousejack/nrf-research-firmware install

nrf24-flash-logitech:
	$(MAKE) -C ${TMPDIR}/nrf24-arsenal/mousejack/nrf-research-firmware logitech_install

nrf24-flash-crazyradio:
	cd ${TMPDIR}/nrf24-arsenal/crazyradio-firmware/usbtools && \
	python launchBootloader.py && \
	python nrfbootload.py flash bin/cradio.bin
################################## nrf24 #######################################

################################## reverse ######################################
##: reverse-deps - install dependencies for reverse engineering
reverse-deps:
	apt-get install -y libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 libbz2-1.0:i386

##: reverse-android - install tools for reverse Android engineering
reverse-android: dev-android dev-java
	apt-get install -y abootimg smali android-sdk apktool dex2jar

##: reverse-firmware - install firmware RE/MOD tools
reverse-firmware:
	apt-get install firmware-mod-kit -y
	@echo "install sasquatch to extract non-standard SquashFS images"
	$(call gitclone,https://github.com/devttys0/sasquatch)
	cd $(repo) && ./build.sh  # make && sudo make install
	@echo "installing binwalk"
	$(call gitclone,https://github.com/devttys0/binwalk)
	cd $(repo) && y| ./deps.sh && pip install .
	@echo "installing firmadyne"
	$(call gitclone,https://github.com/firmadyne/firmadyne)
	@echo "installing firmwalker"
	$(call gitclone,https://github.com/craigz28/firmwalker)

##: reverse-disasm - install disassemblers for RE
reverse-disasm:
	@apt install capstone radare2 -y

##: reverse-debug - install debuggers for RE
reverse-debug:
	@apt install gdb voltron frida -y

##: reverse-avatar - install Avatar symbol execution
reverse-avatar:
	@echo "install all build-deps"
	apt-get build-dep qemu llvm
	apt-get install -y liblua5.1-dev libsdl1.2-dev libsigc++-2.0-dev binutils-dev python-docutils python-pygments nasm
	@echo "Get the source code from github"
	$(call gitclone,https://github.com/eurecom-s3/s2e)
	@echo "It will take some time to build..."
	cd $(repo) && mkdir build && cd build && make -j -f ../s2e/Makefile
	@echo "installing Avatar module from github"
	# http://llvm.org/devmtg/2014-02/slides/bruno-avatar.pdf
	pip3 install git+https://github.com/eurecom-s3/avatar-python.git#egg=avatar
	# install all build-deps
	apt-get build-dep openocd
	git clone --recursive git://git.code.sf.net/p/openocd/code $(TMPDIR)/openocd
	cd $(TMPDIR)/openocd && autoreconf -i && ./configure --prefix=$(PREFIX) && make -j && make install
################################## reverse ######################################


################################# hardware #####################################
diy:
	apt-get install -y  python-rpi.gpio python-smbus i2c-tools
	pip install spidev

##: hardware - install generic hardware hacking tools
hardware-generic:	deps dev
	@echo "installing hardware hacking tools"
	apt-get install -y ftdi-eeprom libftdi1 python-ftdi1 python3-ftdi1 minicom \
	python-serial cutecom libftdi-dev skyeye flashrom libusb-1.0-0-dev \
	arduino esptool # openocd

##: hardware-signal - install signal analysis tools
hardware-signal:
	# TODO: OLS install
	apt-get install -y libsigrok0-dev sigrok-cli libsigrokdecode0-dev autoconf-archive \
	libglib2.0-dev libglibmm-2.4-dev libzip-dev check default-jdk libqt4-dev libboost-dev \
	libboost-system-dev libglib2.0-dev libqt4-dev libboost-test-dev libboost-thread-dev \
	libboost-filesystem-dev
	$(call gitclone,git://sigrok.org/libserialport)
	cd $(repo) && ./autogen.sh && ./configure && make && make install
	$(call gitclone,git://sigrok.org/libsigrok)
	cd $(repo) && ./autogen.sh && ./configure && make && make install
	$(call gitclone,git://sigrok.org/pulseview)
	cd $(repo) && cmake . && make && make install
################################# hardware #####################################

################################# summary ######################################
#: deps - install basic dependecies and common tools            *
deps:	archivers common
#: dev-all - install ALL development tools                      *
dev-all: deps dev-vcs dev-python dev-build dev-crypto dev-network dev-ide dev-java dev-crossdev
#: dev-mini - install ALL development tools                     *
dev-mini: deps dev-vcs dev-python dev-build dev-crypto dev-network
#: wifi-deauth - tools for 80211 deauth: wifijammer, zizzania   *
wifi-deauth: wifijammer zizzania
#: wifi-wpa - isetup ALL attacks on WPA/WPA2/WPA-Enterprise     *
wifi-wpa: wifi-deauth wifite airgeddon handshaker
#: wifi-wps - install ALL WPS pwning tools and scripts          *
wifi-wps: penetrator pixiewps wpsik reaver
#: wifi-all - install ALL tools for Wi-Fi hacking               *
wifi-all: fresh dev wifi-rogueap python-wifi wifi-autopwn wifi-wps wifi-wpa
#: nrf24 - Nordic Semiconductor NRF24XXX hacking tools          *
nrf24:	nrf24-deps nrf24-firmware
#: ism - soft for unlicensed bands: 433/866/915Mhz 2.4Ghz       *
ism: subghz nrf24 wifi bluetooth
#: reverse - install tools for RE (reverse engineering)         *
reverse: reverse-deps reverse-avatar
#: hardware - install hardware hacking tools                    *
hardware: hardware-generic hardware-signal
#: all - install EVERYTHING from EVERY category                 *
all: clean upgrade wireless hardware firmware
################################# summary ######################################
