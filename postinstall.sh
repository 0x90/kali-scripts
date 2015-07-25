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
        nautilus-open-terminal lintian lzma patchutils strace wdiff linux-headers-`uname -r` winetricks shellnoob

        print_status "Installing shell tools.."
        apt-get install -y terminator zip gnome-tweak-tool htop mc synapse ack-grep netcat-openbsd xsel screen

        print_status "Installing ARP tools"
        apt-get install -y arp-scan arpalert arping arpwatch

        print_status "Installing unpackers.."
        apt-get -y install unace rar unrar p7zip zip unzip p7zip-full p7zip-rar sharutils uudeview mpack arj cabextract file-roller
    fi

    #TODO: check this shit.
    if ask "Do you want to install Windowstools?" N; then
        apt-get -y install windows-binaries
        mkdir -p /var/www/tools/shells && chmod -R 755 /var/www/tools
        cp /usr/share/windows-binaries/{nc.exe,plink.exe,vncviewer.exe,wget.exe} /var/www/tools/
        wget -c http://winscp.net/download/winscp514.zip -O /tmp/winscp514.zip && unzip /tmp/winscp514.zip
        cp /tmp/WinSCP.exe /var/www/tools/scp.exe
        rm /tmp/winscp*
        rm /tmp/readme.txt
        rm /tmp/WinSCP*
    fi

    if ask "Do you want to install meld (graphical diff tool)?" N; then
        apt-get -y install meld
        gconftool-2 --type bool --set /apps/meld/show_line_numbers true
        gconftool-2 --type bool --set /apps/meld/show_whitespace true
        gconftool-2 --type bool --set /apps/meld/use_syntax_highlighting true
        gconftool-2 --type int --set /apps/meld/edit_wrap_lines 2
    fi

    if ask "Do you want to install pidgin and an OTR chat plugin?" N; then
        apt-get -y install pidgin pidgin-otr
    fi

    if ask "Install Dropbox? " Y; then
        apt-get install -y nautilus-dropbox
    fi
}


install_zsh(){
    if ask "Do you want to install zsh?" Y; then
        apt-get install zsh -y
    fi

    if ask "Do you want to install oh-my-zsh?" Y; then
        if command_exists curl ; then
            curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
        elif command_exists wget ; then
            wget --no-check-certificate https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O - | sh
        fi
    fi
}

install_skype(){
    dpkg --add-architecture i386
    apt-get update -y

    cd /tmp
    wget -O skype-install.deb http://www.skype.com/go/getskype-linux-deb
    dpkg -i skype-install.deb

    apt-get install gdebi
    apt-get -f install

    #
    apt-get autoclean
}


config_ssh(){
    print_status "Сonfiguring sshd. Current OpenSSH status:"
    service ssh status

    #TODO: check this!
    if ask "Do you want to install fresh sshd/ssh keys? (might be good if you're using the vmware image)" N; then
        print_status "Removing old host keys.."
        rm -rf /etc/ssh/ssh_host_*
        success_check
        print_status "Regenerating host keys.."
        dpkg-reconfigure openssh-server
        success_check

        mkdir /etc/ssh/default_kali_keys
        mv /etc/ssh/ssh_host* /etc/ssh/default_kali_keys/
        dpkg-reconfigure openssh-server
        echo "please make sure that those keys differ"
        md5sum /etc/ssh/default_kali_keys/*
        md5sum /etc/ssh/ssh_host*
        service ssh try-restart
        ssh-keygen -t rsa -b 2048
    fi

    if "Enable X11 Forwarding support" Y; then
        sed -i -e 's/\#X11Forwarding no/X11Forwarding yes/' /etc/ssh/sshd_config
        sed -i -e 's/\#X11DisplayOffset/X11DisplayOffset/' /etc/ssh/sshd_config
        sed -i -e 's/\#X11UseLocalhost/X11UseLocalhost/' /etc/ssh/sshd_config
        sed -i -e 's/\#AllowTcpForwarding/AllowTcpForwarding/' /etc/ssh/sshd_config
    fi

    if "Enable sshd to start on boot?" Y; then
        apt-get install chkconfig -y
        chkcofig ssh on
    fi

    if "Enabling visual hostkeys in your .ssh/config?" Y; then
        mkdir -p ~/.ssh && echo "VisualHostKey=yes" >> ~/.ssh/config
    fi

    if ask "Start sshd?" Y; then
        service ssh start
    fi
}


if ask "Configure SSH?" Y; then
    config_ssh
fi


apt-get install vidalia privoxy -y

echo forward-socks4a / 127.0.0.1:9050 . >> /etc/privoxy/config

mkdir -p /var/run/tor
chown debian-tor:debian-tor /var/run/tor
chmod 02750 /var/run/tor

/etc/init.d/tor start
/etc/init.d/privoxy start

#USE SOCKS PROXY 127.0.0.1:9059




tweak(){
    if ask "Enable SSH?" Y; then
        update-rc.d ssh enable && update-rc.d ssh defaults
        /etc/init.d/ssh start
    fi

    #TODO: check and fix!
    if ask "Do you want to auto login on startup?" Y; then
        sed -i 's,#  Automatic,Automatic,g' /etc/gdm3/daemon.conf
    fi

    if ask "MSF first init. Do you want to install armitage,postgres,metasploit to run on boot?" Y; then
        update-rc.d postgresql enable && update-rc.d metasploit enable

        # MSF first init.
        service postgresql start
        service metasploit stop
        service metasploit start
        msfupdate
        echo exit > /tmp/msf.rc
        msfconsole -r /tmp/msf.rc
        rm /tmp/msf.rc
    fi

    #TODO: fix ^m issues
    if ask "Install bash alises and other speed hacks?" N; then
        echo "Installing ~/.bash_aliases"
        if [ -d ~/.bash_aliase ]; then
            print_notification "~/.bash_aliase found, backuping to ~/bash_aliases.bak"
            cp ~/.bash_aliases ~/bash_aliases.bak
        fi
        wget http://pastebin.com/raw.php?i=xd9qErmK -O ~/.bash_aliases


        echo "Installing ~/.screenrc"
        if [ -d ~/.screenrc ]; then
            print_notification "~/.screenrc found, backuping to ~/.screenrc.bak"
            cp ~/.screenrc ~/.screenrc.bak
        fi
        wget http://pastebin.com/raw.php?i=7kC03vaD -O ~/.screenrc
    fi

    if ask "Do you want to change the grub default timeout to 0 sec?" N; then
        sed -i -e "s,^GRUB_TIMEOUT=.*,GRUB_TIMEOUT=0," /etc/default/grub
        echo "GRUB_HIDDEN_TIMEOUT=0" >> /etc/default/grub
        echo "GRUB_HIDDEN_TIMEOUT_QUIET=true" >> /etc/default/grub
        update-grub
    fi

    if ask "Do you want a different hostname on every boot?" N; then
        grep -q "hostname" /etc/rc.local hostname || sed -i 's#^exit 0#hostname $(cat /dev/urandom | tr -dc "A-Za-z" | head -c8)\nexit 0#' /etc/rc.local
    fi

    if ask "Do you want to enable numlock on boot?" N; then
        apt-get -y install numlockx
        cp -n /etc/gdm3/Init/Default{,.bkup}
        grep -q '/usr/bin/numlockx' /etc/gdm3/Init/Default || sed -i 's#exit 0#if [ -x /usr/bin/numlockx ]; then\n/usr/bin/numlockx on\nfi\nexit 0#' /etc/gdm3/Init/Default
    fi

}

install_postinstall(){
    # Main code here.
    check_euid
    install_packages
    install_zsh
    tweak
    apt_cleanup
}