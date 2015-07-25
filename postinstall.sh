#!/usr/bin/env bash
#
. helper.sh

install_packages(){
    if ask "Install common tools (mostly fixes and essentials) ?" Y; then
        print_status "Adding some essential packages."
        apt-get install -y cifs-utils ibssl-dev hostapd ipcalc cmake cmake-data \
        emacsen-common libltdl-dev libpcap0.8-dev libtool libxmlrpc-core-c3 filezilla gedit recon-ng xdotool \
         curl build-essential openssl libreadline6 libreadline6-dev git-core zlib1g zlib1g-dev \
        libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev bison libmysqlclient-dev libmagickcore-dev \
        libmagick++-dev libmagickwand-dev libnetfilter-queue-dev autotools-dev cdbs check checkinstall dctrl-tools debian-keyring \
        devscripts dh-make diffstat dput equivs libapt-pkg-perl libauthen-sasl-perl libclass-accessor-perl libclass-inspector-perl \
        libcommon-sense-perl libconvert-binhex-perl libcrypt-ssleay-perl libdevel-symdump-perl libfcgi-perl libhtml-template-perl \
        libio-pty-perl libio-socket-ssl-perl libio-string-perl libio-stringy-perl libipc-run-perl libjson-perl libjson-xs-perl libmime-tools-perl\
        libnet-libidn-perl libnet-ssleay-perl libossp-uuid-perl libossp-uuid16 libparse-debcontrol-perl libparse-debianchangelog-perl \
        libpod-coverage-perl libsoap-lite-perl libsub-name-perl libtask-weaken-perl libterm-size-perl libtest-pod-perl \
        libxml-namespacesupport-perl libxml-sax-expat-perl libxml-sax-perl libxml-simple-perl libyaml-syck-perl \
        nautilus-open-terminal lintian lzma patchutils strace wdiff linux-headers-`uname -r`

        print_status "Installing shell tools.."
        apt-get install -y terminator zip gnome-tweak-tool htop mc synapse ack-grep netcat-openbsd xsel screen

        print_status "Installing unpackers.."
        apt-get -y install unace rar unrar p7zip zip unzip p7zip-full p7zip-rar sharutils uudeview mpack arj cabextract file-roller
    fi

}

install_packages
apt_cleanup