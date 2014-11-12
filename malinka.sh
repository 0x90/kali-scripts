#!/bin/sh
# https://github.com/pwnieexpress/raspberry_pwn/blob/master/INSTALL_raspberry_pwn.sh

# Verify we are root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

## SSh
rm /etc/ssh/ssh_host_*
dpkg-reconfigure openssh-server
service ssh restart

#root password
passwd root

# clean old pkg
apt-get remove iceweasel xulrunner-24.0 -y

#update
apt-get update && apt-get upgrade -y

apt-get install kali-linux-wireless kali-linux-sdr

if ask "Install pip & python modules" Y; then
    apt-get -y install python-pip python-twisted python-virtualenv
#        pip install shodan mysql-python python-ntlm scipy selenium tornado netaddr matplotlib paramiko lxml pcapy \
#        GitPython PyGithub SOAPpy SQLAlchemy Jinja2 readline nose six pyparsing==1.5.7 python-dateutil tornado==3.1.1 \
#        pyzmq pytz pika pygments scipy patsy
fi


apt-get install metasploit beef recon-ng

if ask "Install kali-linux-wireless?" Y; then
    apt-get install kali-linux-wireless mana-toolkit kismet wifite

    if ask "Install horst?" Y; then
        apt-get install libncurses5-dev -y
        git clone git://br1.einfach.org/horst /usr/src/horst
        cd /usr/src/horst
        make
        cp horst /usr/bin/
    fi

pt-get install libnetfilter-conntrack-dev libnetfilter-conntrack3 iptstate libnl-nf-3-200 python-netfilter libpcap-dev

#    if ask "Install latest scapy?" Y; then
#        echo "Installing Scapy dependencies"
#        apt-get install tcpdump graphviz imagemagick python-gnuplot python-crypto python-pyx wireshark -y
#
#        #pip install -e hg+https://bb.secdev.org/scapy#egg=scapy --insecure
#        cd /tmp
#        hg clone https://bb.secdev.org/scapy --insecure
#        cd scapy
#        ./setup.py install
#    fi
#
#    if ask "Install scapytain?" N; then
#
#        apt-get install -y python-cherrypy3 graphviz python-genshi python-sqlobject python-formencode python-pyopenssl highlight python-trml2pdf python-pip
#        # pip install   http://www.satchmoproject.com/snapshots/trml2pdf-1.2.tar.gz
#        pip install pyopenssl
#
#        #pip install -e hg+ --insecure
#        # udo pip install -e hg+http://bb.secdev.org/scapytain#egg=scapytain --insecure
#        cd /tmp
#        hg clone https://bb.secdev.org/scapytain --insecure
#        cd scapytain
#        ./setup.py install
#
#        mcedit /etc/scapytainrc
#        mkdir /var/lib/scapytain
#        scapytain_dbutil -c
#
#    fi


    if ask "Install Lorcon?" Y; then
        echo "Installing Lorcon dependecies"
        apt-get install libpcap0.8-dev libnl-dev libnl1

        #Requires lorcon2:
        echo "Installing Lorcon"
        cd /tmp
        git clone https://code.google.com/p/lorcon
        cd lorcon
        ./configure
        make && make install

        #Cleanup
        cd /tmp
        rm -rf /tmp/lorcon/* && rm -rf /tmp.lorcon/.git* && rmdir lorcon


        echo "Install pylorcon2"
        cd /tmp
        svn checkout http://pylorcon2.googlecode.com/svn/trunk/ pylorcon2

        # git clone https://github.com/tom5760/pylorcon2
        cd pylorcon2
        python setup.py build
        python setup.py install


#        Deps required
#        pylorcon from the lorcon trunk. https://code.google.com/p/lorcon/
#        pylibpcap http://sourceforge.net/projects/pylibpcap/
#        git clone https://github.com/signed0/pylibpcap.git
#    cd pylibpcap
#     ./setup.py install

    fi



#pip install -e git+https://github.com/signed0/pylibpcap#egg=pylibpcap
#    git clone https://github.com/signed0/pylibpcap.git
#    cd pylibpcap
#     ./setup.py install




    git clone https://code.google.com/p/py80211/
    cd py80211
     ./setup.py install


    if ask "Install FruityWifi?" Y; then
        apt-get isntall php5-fpm -y
        wget https://github.com/xtr4nge/FruityWifi/archive/master.zip
        unzip FruityWifi.zip
        cd FruityWifi-master/
        ./install-FruityWifi.sh
        ./install-modules.py
    fi

    if ask "Install MITMf?" Y; then
        git clone https://github.com/byt3bl33d3r/MITMf
        cd MITMf
        ./setup.sh
    fi




    if ask "Install latest scapy?" Y; then
        echo "Installing Scapy dependencies"
        apt-get install tcpdump graphviz imagemagick python-gnuplot python-crypto python-pyx wireshark -y

        #pip install -e hg+https://bb.secdev.org/scapy#egg=scapy --insecure
        cd /tmp
        hg clone https://bb.secdev.org/scapy --insecure
        cd scapy
        ./setup.py install
    fi

    if ask "Install scapytain?" N; then

        apt-get install -y python-cherrypy3 graphviz python-genshi python-sqlobject python-formencode python-pyopenssl highlight python-trml2pdf python-pip
        # pip install   http://www.satchmoproject.com/snapshots/trml2pdf-1.2.tar.gz
        pip install pyopenssl

        #pip install -e hg+ --insecure
        # udo pip install -e hg+http://bb.secdev.org/scapytain#egg=scapytain --insecure
        cd /tmp
        hg clone https://bb.secdev.org/scapytain --insecure
        cd scapytain
        ./setup.py install

        mcedit /etc/scapytainrc
        mkdir /var/lib/scapytain
        scapytain_dbutil -c

    fi

#### SDR
#git clone https://github.com/kpreid/shinysdr
#fetch-js-deps.sh
#cd shinysdr
#python setup.py install
#
## http://www.mike-stirling.com/redmine/projects/webradio/wiki/Installation
#
### FM
#http://razzpisampler.oreilly.com/ch01.html
#https://github.com/Make-Magazine/PirateRadio
#https://github.com/wdlindmeier/magpiradio
#https://github.com/Manawyrm/FMBerry
#https://github.com/ChristopheJacquet/PiFmRds
#
#http://omattos.com/pifm.tar.gz
#
###
#https://github.com/klausmcm/universal-remote