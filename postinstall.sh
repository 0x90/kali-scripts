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

#        print_status "Installing ARP tools"
#        apt-get install -y arp-scan arpalert arping arpwatch

        print_status "Installing unpackers.."
        apt-get -y install unace rar unrar p7zip zip unzip p7zip-full p7zip-rar sharutils uudeview mpack arj cabextract file-roller
    fi
#
#    #TODO: check this shit.
#    if ask "Do you want to install Windowstools?" N; then
#        apt-get -y install windows-binaries
#        mkdir -p /var/www/tools/shells && chmod -R 755 /var/www/tools
#        cp /usr/share/windows-binaries/{nc.exe,plink.exe,vncviewer.exe,wget.exe} /var/www/tools/
#        wget -c http://winscp.net/download/winscp514.zip -O /tmp/winscp514.zip && unzip /tmp/winscp514.zip
#        cp /tmp/WinSCP.exe /var/www/tools/scp.exe
#        rm /tmp/winscp*
#        rm /tmp/readme.txt
#        rm /tmp/WinSCP*
#    fi
#
#    if ask "Do you want to install meld (graphical diff tool)?" N; then
#        apt-get -y install meld
#        gconftool-2 --type bool --set /apps/meld/show_line_numbers true
#        gconftool-2 --type bool --set /apps/meld/show_whitespace true
#        gconftool-2 --type bool --set /apps/meld/use_syntax_highlighting true
#        gconftool-2 --type int --set /apps/meld/edit_wrap_lines 2
#    fi
}

install_postinstall(){
    install_packages
    apt_cleanup
}