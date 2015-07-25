#!/usr/bin/env bash


apt_upgrade(){
    apt-get update && apt-get upgrade -y
}

apt_super_upgrade(){
    apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y
}

apt_cleanup(){
    apt-get -y autoremove && apt-get -y clean
}

apt_install_add_repo(){
    sudo cp ./add-apt-repository.sh /usr/sbin/add-apt-repository
#    print_status "Downloading to /usr/sbin/add-apt-repository.."
#    wget http://blog.anantshri.info/content/uploads/2010/09/add-apt-repository.sh.txt -O /usr/sbin/add-apt-repository
    chmod o+x /usr/sbin/add-apt-repository
}

apt_add_sources(){
    echo "$0" > "/etc/apt/sources.list.d/$1.list"
}

apt_add_repo(){
    if [ ! -f /usr/sbin/add-apt-repository ]; then
        echo "File /usr/sbin/add-apt-repository not found! Installing..."
        apt_install_add_repo
    fi
    add-apt-repository "$0" && apt-get update -y
}

apt_add_key(){
    wget -q "$0" -O- | sudo apt-key add -
}