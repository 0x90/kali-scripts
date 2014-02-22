#!/bin/bash
. ask.sh

ask "do you want to install kali-post-install-commons? (mostly fixes and essentials) ?" Y || exit 3

# fix wash
apt-get -y install libsqlite3-dev
mkdir -p /etc/reaver

# install compiling essentials and tools
apt-get -y install build-essential autotools-dev cdbs check checkinstall dctrl-tools debian-keyring devscripts dh-make diffstat dput equivs
apt-get -y libapt-pkg-perl libauthen-sasl-perl libclass-accessor-perl libclass-inspector-perl libcommon-sense-perl libconvert-binhex-perl libcrypt-ssleay-perl libdevel-symdump-perl libfcgi-perl libhtml-template-perl libio-pty-perl libio-socket-ssl-perl libio-string-perl libio-stringy-perl libipc-run-perl libjson-perl libjson-xs-perl libmime-tools-perl libnet-libidn-perl libnet-ssleay-perl libossp-uuid-perl libossp-uuid16 libparse-debcontrol-perl libparse-debianchangelog-perl libpod-coverage-perl libsoap-lite-perl libsub-name-perl libtask-weaken-perl libterm-size-perl libtest-pod-perl libxml-namespacesupport-perl libxml-sax-expat-perl libxml-sax-perl libxml-simple-perl libyaml-syck-perl
apt-get -y lintian lzma patchutils strace wdiff linux-headers-`uname -r` winetrick

# fix possible sqlmap requirement
apt-get -y install python-pip
pip-2.6 install python-ntlm
pip-2.7 install python-ntlm

# shell tools
apt-get install -y terminator zip gnome-tweak-tool htop mc synapse ack-grep netcat-openbsd xsel

# arp
apt-get install -y arp-scan arpalert arping arpwatch

# unpackers
apt-get -y install unace rar unrar p7zip zip unzip p7zip-full p7zip-rar sharutils uudeview mpack arj cabextract file-roller

# enable real transparency
gsettings set org.gnome.metacity compositing-manager true
