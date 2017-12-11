#!/usr/bin/env bash
# Install and configure commonly used tools
. helper.sh

install_archivers(){
    print_status "Installing archivers.."
    apt-get -y install gzip bzip2 tar lzma arj lhasa p7zip-full cabextract unace rar unrar zip unzip \
    sharutils uudeview mpack arj cabextract file-roller zlib1g zlib1g-dev liblzma-dev liblzo2-dev
}

install_32bit(){
    if [ `getconf LONG_BIT` = "64" ] ; then
        if ask "64-bit OS detected. Installing 32-bit libs?" Y; then
            dpkg --add-architecture i386 && apt-get update -y && apt-get install lib32z1 lib32ncurses5 -y
            check_success
        fi
    fi
}

install_common_tools(){
    print_status "Installing common tools.."
    apt-get install -y terminator tmux htop iftop iotop mc screen curl wget git
}

install_zsh(){
    apt-get install zsh -y
    if ask "Do you want to install oh-my-zsh?" Y; then
        if command_exists curl ; then
            curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
        elif command_exists wget ; then
            wget --no-check-certificate https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O - | sh
        fi
    fi
}

config_gdm(){
    #TODO: check and fix!
    if ask "Do you want to auto login on startup?" Y; then
        sed -i 's,#  Automatic,Automatic,g' /etc/gdm3/daemon.conf
    fi

    if ask "Do you want to enable numlock on boot?" N; then
        apt-get -y install numlockx
        cp -n /etc/gdm3/Init/Default{,.bkup}
        grep -q '/usr/bin/numlockx' /etc/gdm3/Init/Default || sed -i 's#exit 0#if [ -x /usr/bin/numlockx ]; then\n/usr/bin/numlockx on\nfi\nexit 0#' /etc/gdm3/Init/Default
    fi
}

config_ssh(){
    print_status "Сonfiguring sshd. Current OpenSSH status:"
    service ssh status

    #TODO: check this!
    if ask "Do you want to install fresh sshd/ssh keys? (might be good if you're using the vmware image)" N; then
        print_status "Removing old host keys.."
        rm -rf /etc/ssh/ssh_host_*
        check_success
        print_status "Regenerating host keys.."
        dpkg-reconfigure openssh-server
        check_success

        mkdir /etc/ssh/default_kali_keys
        mv /etc/ssh/ssh_host* /etc/ssh/default_kali_keys/
        dpkg-reconfigure openssh-server
        echo "please make sure that those keys differ"
        md5sum /etc/ssh/default_kali_keys/*
        md5sum /etc/ssh/ssh_host*
        service ssh try-restart
        ssh-keygen -t rsa -b 2048
    fi

    if ask "Enable X11 Forwarding support" Y; then
        sed -i -e 's/\#X11Forwarding no/X11Forwarding yes/' /etc/ssh/sshd_config
        sed -i -e 's/\#X11DisplayOffset/X11DisplayOffset/' /etc/ssh/sshd_config
        sed -i -e 's/\#X11UseLocalhost/X11UseLocalhost/' /etc/ssh/sshd_config
        sed -i -e 's/\#AllowTcpForwarding/AllowTcpForwarding/' /etc/ssh/sshd_config
    fi

    if ask "Enable SSHD to start on boot?" Y; then
        update-rc.d ssh enable
    fi

    if ask "Enabling visual hostkeys in your .ssh/config?" Y; then
        mkdir -p ~/.ssh && echo "VisualHostKey=yes" >> ~/.ssh/config
    fi

    if ask "Start sshd?" Y; then
        service ssh start
    fi
}

config_metasploit(){
    update-rc.d postgresql enable && update-rc.d metasploit enable

    # MSF first init.
    service postgresql start
    service metasploit stop
    service metasploit start
    msfupdate
#    echo exit > /tmp/msf.rc
#    msfconsole -r /tmp/msf.rc
#    rm /tmp/msf.rc
}

config_grub(){
    sed -i -e "s,^GRUB_TIMEOUT=.*,GRUB_TIMEOUT=0," /etc/default/grub
    echo "GRUB_HIDDEN_TIMEOUT=0" >> /etc/default/grub
    echo "GRUB_HIDDEN_TIMEOUT_QUIET=true" >> /etc/default/grub
    update-grub
}

config_personal(){
    print_status "Installing ~/.screenrc"
    write_with_backup files/home/bash_aliases ~/.screenrc

    print_status "Installing ~/.bash_aliases"
    write_with_backup files/home/bash_aliases ~/.bash_aliases
}

postinstall(){
    if ask "Install common tools (mostly fixes and essentials)?" Y; then
        print_status "Adding some essential packages."
        apt-get install -y cifs-utils libssl-dev ipcalc  \
        emacsen-common libltdl-dev libpcap0.8-dev libtool libxmlrpc-core-c3 xdotool openssl libreadline6 libreadline6-dev  \
        libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libc6-dev libncurses5-dev bison libmysqlclient-dev libmagickcore-dev \
        libmagick++-dev libmagickwand-dev libnetfilter-queue-dev autotools-dev cdbs check checkinstall dctrl-tools debian-keyring \
        devscripts dh-make diffstat dput equivs libapt-pkg-perl libauthen-sasl-perl libclass-accessor-perl libclass-inspector-perl \
        libcommon-sense-perl libconvert-binhex-perl libcrypt-ssleay-perl libdevel-symdump-perl libfcgi-perl libhtml-template-perl \
        libio-pty-perl libio-socket-ssl-perl libio-string-perl libio-stringy-perl libipc-run-perl libjson-perl libjson-xs-perl libmime-tools-perl\
        libnet-libidn-perl libnet-ssleay-perl libossp-uuid-perl libossp-uuid16 libparse-debcontrol-perl libparse-debianchangelog-perl \
        libpod-coverage-perl libsoap-lite-perl libsub-name-perl libtask-weaken-perl libterm-size-perl libtest-pod-perl \
        libxml-namespacesupport-perl libxml-sax-expat-perl libxml-sax-perl libxml-simple-perl libyaml-syck-perl lintian

        install_32bit
        install_common_tools

        if ask "Install archivers?" Y; then
            install_archivers
        fi

        if ask "Install ZSH and oh-my-zsh?" Y; then
            install_zsh
        fi
    fi

    if ask "Config SSH?" Y; then
        config_ssh
    fi

    if ask "MSF first init. Do you want to install armitage,postgres,metasploit to run on boot?" Y; then
        config_metasploit
    fi

    if ask "Install personal config: bash alises and other speed hacks?" N; then
        config_personal
    fi

    if ask "Configure GDM options (Autologon, NumLock)?" N; then
        config_gdm
    fi

    if ask "Do you want to change the grub default timeout to 0 sec?" N; then
        config_grub
    fi

    if ask "Do you want a different hostname on every boot?" N; then
        grep -q "hostname" /etc/rc.local hostname || sed -i 's#^exit 0#hostname $(cat /dev/urandom | tr -dc "A-Za-z" | head -c8)\nexit 0#' /etc/rc.local
    fi
}

if [ "${0##*/}" = "postinstall.sh" ]; then
    postinstall
fi
