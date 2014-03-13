#!/bin/bash
. helper.sh

update(){
    print_status "[*] Updating the entire system."
    print_status "Performing apt-get update -y && apt-get upgrade"
    apt-get update -y && apt-get upgrade && apt-get -y dist-upgrade
    success_check

    print_status "[*] Updating MSF..."
    print_notification "This may also take a little while to run. Not nearly as long as a full update did."
    msfupdate
    cd /opt/metasploit/apps/pro/msf3/
    bundle install
    success_check

    print_status "[*]Making sure MSF startups on boot."
    ls /etc/rc* | grep "S..metasploit"
    if [ $? -eq 1 ]; then
        update-rc.d postgresql enable && update-rc.d metasploit enable
        success_check
    fi
}

bleeding_edge(){
    #TODO: add checl if already switched ti bleeding edge
    print_status "Adding kali bleeding edge repo to /etc/apt/sources.list.."
    out=`grep  "kali-bleeding-edge" /etc/apt/sources.list`
    if [[ "$out" !=  *kali-bleeding-edge* ]]; then
        echo "# bleeding edge repository" >> /etc/apt/sources.list
        echo "deb http://repo.kali.org/kali kali-bleeding-edge main" >> /etc/apt/sources.list
        echo "deb http://http.kali.org/kali kali main non-free contrib" >> /etc/apt/sources.list
        echo "deb http://security.kali.org/kali-security kali/updates main contrib non-free" >> /etc/apt/sources.listi
    fi
    update
}

check_euid
if ask "Switch to bleeding edge?" Y; then
    bleeding_edge
elif ask "Update & upgrade Kali Linux?" Y; then
    update
fi