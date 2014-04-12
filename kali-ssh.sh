#!/bin/bash
. helper.sh

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
