# EZ Kali scripts [UNTESTED]

Welcome to Kali Linux dirty script rip off
Every script can be launched separately, except helper.sh - functions module

# READ SCRIPT BEFORE EXECUTING!

# Half tested and working:
    kali-mobile.sh
    kali-tweaks.sh
    kali-embedded.sh
    kali-post-install.sh
    kali-update.sh
    kali-build-live.sh
    kali-gnome.sh
    kali-xfce.sh
    kali-sec-tools.sh

# Description & ideas

Short description. Please review before launching. Feel free to commit.

    ezkali.sh - main launcher with args
    helper.sh - misc functions
    kali-build-live.sh - build your own kali live iso
    kali-embedded.sh - installation script for ARM/MIPS crossdev + linaro toolchains
    kali-gnome.sh - gnome3 tweaks. Does't work over ssh coz of X11 session
    kali-kernel.sh - kernel recompilation script NOT READY!
    kali-mirror.sh - create mirror NOT READY!
    kali-mobile.sh - tools for iOS/Android hacking
    kali-post-install.sh - post install of basic and useful stuff
    kali-sec-tools.sh - various security tools from bin and src
    kali-tweaks.sh - Kali Linux tweaks (autologin, grub) + .bash_aliases speed hacks
    kali-update.sh - update + upgrade + switch to bleeding edge
    kali-video.sh - nVidia/ATI drivers installation. NOT READY!
    kali-vm.sh - detect VM 8) and install VM tools (vbox, vmware, parallels) NOT READY!
    kali-wipe.sh - logz wiping (wifi, auth, history, etc, wtf) NOT READY!
    kali-xfce.sh - XFCE4 installation and tune up script. Do you realy need Gnome 3 on VM?
    ubuntu2kali.sh - make Kali from Ubuntu. NOT READY!


# Some usefull scripts for Kali Linux


http://cdimage.kali.org/kali-latest/amd64/kali-linux-1.0.6-amd64.iso
http://cdimage.kali.org/kali-latest/i386/kali-linux-1.0.6-i386.iso
http://cdimage.kali.org/kali-latest/armel/kali-linux-1.0.6-armel.img.xz
http://cdimage.kali.org/kali-latest/armhf/kali-linux-1.0.6-armhf.img.xz

http://www.offensive-security.com/kali-llnux-vmware-arm-image-download/

#OR BUILD YOUR OWN CUSTOM ISO.
apt-get install git live-build cdebootstrap
git clone git://git.kali.org/live-build-config.git
cd live-build-config
lb config
lb build


https://aws.amazon.com/marketplace/pp/B00HW50E0M


======================================================
======================================================
This script is to install the Cisco VPN client for linux
on the Kali distrobution. This is all licensed
under the GPLv3 and is maintained by James Luther.

Recently during a pentest I had to connect to the systems
that were being tested by using a Cisco VPN which only
supported certificate based authentication. This normally
isn't an issue but I use a custom build of Kali during
penetration tests unless we find something specific that
we want to target which then we move on to one of the
special/specific linux builds. Either way I couldn't vpn
from the pentesting workstation. Initially I used
proxychains to make my tools available then I broke down
and did this. I certainly hope it saves some of you time
and effort.  Enjoy!

=======================================================
WARNING!!
=======================================================

If you are running a 64 bit version of Kali you must
install ia32-libs! If you don't install this you will
receive a "No such file or directory" error when
attempting to run the vpnclient or any of the newly
installed cisco software. There is an additional script
in the folder downloaded from git repo that does this
for you. It is named 64-Bit. This will be incorporated
into the installer script in newer versions. Until
then it needs to be ran manually.

=======================================================
Installing Cisco VPN Client in Kali
=======================================================

1. Clone this repository on your local machine.

2. Run VPN-Installer script.

3. Import user certificates.
	3a. The only certificate needed is the DS p12
	3b. Certificates are imported using:
		cisco_cert_mgr -U -op import
	    Follow the onscreen instructions from there.

4. Copy your connection profile from a windows machine.
	4a. Profile connections are stored:
		C:\Program Files (x86)\Cisco Systems\VPN Client\Profiles
	4b. Copy the connection profile to the Profiles location on Backtrack
		/etc/opt/cisco-vpnclient/Profiles/
    4c. You can also create your own. I'm not going into that though.

5. Edit your Profile Configuration File (.pcf) to show the certificate store used in linux.
	5a. vi /etc/opt/cisco-vpnclient/Profiles/xxxxx.pcf
	5b. The field "CertStore=2" needs to be changed to "CertStore=1"

6. Verify all certificates are installed correctly.
	6a. cisco_cert_mgr -U -op verify
            Follow the on screen instructions and verify all imported certificates
	    cisco_cert_mgr -R -op verify
	    Again, follow the on screen instructions and verify all imported certificates

7. Start the vpn service
	7a. /etc/init.d/vpnclient_init start

8. Connect the vpn
	8a. vpnclient connect xxxx <-- this is the name of your connection profile.  There is no need to put the full path or .pcf



## Bluetooth

 https://github.com/greatscottgadgets/ubertooth/wiki/Build-Guide
 http://www.splitbits.com/2014/05/14/ubertooth-spectools-chromebook/
 http://penturalabs.wordpress.com/2013/09/01/ubertooth-open-source-bluetooth-sniffing/
 
##SDR

# TODO: Add SDR support
 http://labs.inguardians.com/
 http://nutaq.com/en/blog/complete-model-based-pc-fpga-sdr-development-environment-gnu-radio
 http://funoverip.net/2014/07/gnu-radio-cc1111-packets-encoderdecoder-blocks/
 http://leetupload.com/blagosphere/index.php/2014/03/28/analyze-and-crack-gsm-downlink-with-a-usrp/
 http://g4akw.blogspot.ru/
 http://eliasoenal.com/

 http://www.kubonweb.de/?tag=rtl-sdr

 https://raw.githubusercontent.com/zacinaction/kicksat-groundstation/master/Install-SpriteRadio

 IEEE 802.11
 https://www.ruby-forum.com/topic/4487026
cd /tmp
git clone git://github.com/bastibl/gr-ieee802-11.git
cd gr-ieee802-11
mkdir build
cd build
cmake ..
make
make install
cd /tmp
rm -rf /tmp/gr-ieee802-11

 Digital speech decoder
git clone https://github.com/LinuxSheeple-E/dsd
cd dsd
git checkout Feature/DMRECC
cd dsd
mkdir build
cd build
cmake ..
make

 http://leetupload.com/blagosphere/index.php/2014/03/28/analyze-and-crack-gsm-downlink-with-a-usrp/

## BladeRF
 https://github.com/Nuand/bladeRF
 https://github.com/jmichelp/sdrsharp-bladerf


## DVB
 https://github.com/drmpeg/gr-dvbs
 https://github.com/BogdanDIA/gr-dvbt
 https://github.com/drmpeg/gr-dvbs2

## Digital Speech Decode
 https://github.com/argilo/gr-dsd
 https://github.com/EliasOenal/multimon-ng
 https://github.com/LinuxSheeple-E/dsd

## GPS
 https://github.com/davidhodo/gnuradio_gps

## 802.1X
 https://github.com/bastibl/gr-ieee802-11
 https://github.com/bastibl/gr-ieee802-15-4
 https://github.com/wishi/gr_802.15.4
 https://github.com/UpYou/gr-ieee802-15-5
 https://github.com/septikus/gnuradio-802.15.4-demodulation
 https://code.google.com/p/zigbee-security


## MOBILE NETWORKS ###
 git://git.osmocom.org/gr-osmosdr)
 https://github.com/anastas/gr-cdma
 https://github.com/ptrkrysik/gr-gsm
 https://github.com/scateu/airprobe-3.7-hackrf-patch
 https://github.com/oWCTejLVlFyNztcBnOoh/gr-lte
 https://github.com/NightlyDev/Airprobe-GSM-RCV-GR3.7
 http://sourceforge.net/projects/openbts
 https://github.com/neo4reo/OpenLTE
 http://sourceforge.net/projects/openlte/
 https://github.com/kit-cel/gr-lte
 https://github.com/libLTE/libLTE
 https://github.com/Evrytania/LTE-Cell-Scanner
 https://github.com/JiaoXianjun/rtl-sdr-LTE
 https://github.com/snailpy/ltetoolkit
 https://github.com/tinkerbeast/understanding-lte-in-python

 Code for using GNURadio w/ a USRP
 https://github.com/edwatt/REU2014

#### Blocks
 https://github.com/guruofquality/grex
 https://github.com/guruofquality/grextras
 https://github.com/bistromath/gr-ais
 https://github.com/dl1ksv/gr-display
 https://github.com/fewu/gnuradio_drm
 https://github.com/argilo/gr-qam
 https://github.com/osh/gr-bitcoin
 https://github.com/bistromath/gr-air-modes
 https://github.com/mogar/uhd_ofdm
 https://github.com/glneo/gr-clicker
 https://github.com/scateu/gr-remotecar
 https://github.com/dl1ksv/gr-ax25
 https://github.com/bastibl/gr-rds
 https://github.com/argilo/gr-ham

### Misc
 https://github.com/azorg/gnuradio-examples
 https://github.com/UpYou/gnuradio-tools
 https://github.com/bistromath/gr-scanner
 https://github.com/n-west/gr-west
 https://github.com/urbank/beacon
 https://github.com/piratfm/gr-ssrptx
 https://github.com/argilo/sdr-examples

## Tools
 https://github.com/argilo/ham-utils