#!/usr/bin/env bash
#
. helper.sh


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

    if "Enable SSHD to start on boot?" Y; then
        update-rc.d ssh enable
    fi

    if "Enabling visual hostkeys in your .ssh/config?" Y; then
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
    echo "Installing ~/.screenrc"
    if [ -f ~/.screenrc ]; then
        print_notification "~/.screenrc found, backuping to ~/.screenrc.bak"
        cp ~/.screenrc ~/.screenrc.bak
    fi

    cp files/bash_aliases ~/.screenrc
#    wget http://pastebin.com/raw.php?i=7kC03vaD -O ~/.screenrc

    echo "Installing ~/.bash_aliases"
    if [ -f ~/.bash_aliase ]; then
        print_notification "~/.bash_aliase found, backuping to ~/bash_aliases.bak"
        cp ~/.bash_aliases ~/.bash_aliases.bak
    fi
    cp files/bash_aliases ~/.bash_aliases
#    wget http://pastebin.com/raw.php?i=xd9qErmK -O ~/.bash_aliases

    if ask "Install ZSH and oh-my-zsh?" Y; then
        install_zsh
    fi
}

tweak(){
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

tweak
