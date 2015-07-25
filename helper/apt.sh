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


        print_status "Downloading to /usr/sbin/add-apt-repository.."
        wget http://blog.anantshri.info/content/uploads/2010/09/add-apt-repository.sh.txt -O /usr/sbin/add-apt-repository
        chmod o+x /usr/sbin/add-apt-repository