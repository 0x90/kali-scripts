#!/bin/bash
. helper.sh

tweak(){
    if ask "Install bash alises and other speed hacks?" Y; then
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

    if "Do you want to auto login on startup?" Y; then
        sed -i 's,#  Automatic,Automatic,g' /etc/gdm3/daemon.conf
    fi



    if ask "Do you want to change the grub default timeout to 0 sec?" Y; then
        sed -i -e "s,^GRUB_TIMEOUT=.*,GRUB_TIMEOUT=0," /etc/default/grub
        echo "GRUB_HIDDEN_TIMEOUT=0" >> /etc/default/grub
        echo "GRUB_HIDDEN_TIMEOUT_QUIET=true" >> /etc/default/grub
        update-grub
    fi

    if ask "Do you want a different hostname on every boot?" Y; then
        grep -q "hostname" /etc/rc.local hostname || sed -i 's#^exit 0#hostname $(cat /dev/urandom | tr -dc "A-Za-z" | head -c8)\nexit 0#' /etc/rc.local
    fi

    if ask "Do you want to enable numlock on boot?" Y; then
        apt-get -y install numlockx
        cp -n /etc/gdm3/Init/Default{,.bkup}
        grep -q '/usr/bin/numlockx' /etc/gdm3/Init/Default || sed -i 's#exit 0#if [ -x /usr/bin/numlockx ]; then\n/usr/bin/numlockx on\nfi\nexit 0#' /etc/gdm3/Init/Default
    fi

    if ask "Do you want to install armitage,postgres,metasploit to run on boot?" Y; then
        update-rc.d postgresql enable && update-rc.d metasploit enable

        # MDF init
        service postgresql start
        service metasploit stop
        service metasploit start
        msfupdate
        echo exit > /tmp/msf.rc
        msfconsole -r /tmp/msf.rc
        rm /tmp/msf.rc
    fi

}

check_euid
tweak