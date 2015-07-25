#!/usr/bin/env bash


upgrade(){
    apt-get update && apt-get upgrade -y
}

super_upgrade(){
    apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y
}

cleanup(){
    apt-get -y autoremove && apt-get -y clean
}

install_add_apt(){
    print_status "Downloading to /usr/sbin/add-apt-repository.."
    wget http://blog.anantshri.info/content/uploads/2010/09/add-apt-repository.sh.txt -O /usr/sbin/add-apt-repository
    chmod o+x /usr/sbin/add-apt-repository
}

add_sources(){
    echo "Add VB repo"
    echo >> /etc/apt/sources.list
    echo "deb http://download.virtualbox.org/virtualbox/debian wheezy contrib" >> /etc/apt/sources.list
}

add_repo(){
    #TODO: check if file exists
    add-apt-repository ppa:nilarimogard/webupd8
    apt-get update -y
}

add_key(){
    echo "Add VB key"
    wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | sudo apt-key add -
}