#!/bin/bash
. helper.sh

update_system(){
    print_status "[*] Updating the entire system."
    print_status "Performing apt-get update -y && apt-get upgrade"
    apt-get update -y && apt-get upgrade && apt-get -y dist-upgrade
    success_check
}


#This is where we actually install system updates. Runs apt-get update and apt-get -y dist-upgrade.
#Why a dist-upgrade? because for one reason or another, there are several packages that get "held back"
#With a regular apt-get upgrade. Dist upgrade forces those held back packages to be updated as well.
#On a normal linux distro, you wouldn't do this unless you wanted to do a full distro upgrade, but to my knowledge, for Kali that should be fine.
#This takes a long time, dist-upgrade or no. updating Kali takes a long time, because it pulls like 400+ packages.
distupgrade_system(){

    print_status "Performing apt-get update"
    apt-get update &>> $logfile
    success_check

    print_status "Performing apt-get upgrade"
    print_notification "This WILL take a while. I'm talking at least half an hour (probably longer) on a good connection and fast system. Be patient."
    print_notification "You can monitor the programs through running (in another terminal window):"
    print_notification "tail -f $logfile"
    apt-get -y dist-upgrade &>> $logfile
    success_check
}

bleeding_edge(){
    #adding the kali bleeding edge repo, cuz if it aint' bleeding, it aint for me.
    #print_status "Adding kali bleeding edge repo to /etc/apt/sources.list.."
    #echo "" >> /etc/apt/sources.list
    #echo "#Kali bleeding repository" >> /etc/apt/sources.list
    #echo "deb http://repo.kali.org/kali kali-bleeding-edge main" >> /etc/apt/sources.list
    #success_check
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

update_msf(){

    print_status "Running msfupdate"
    print_notification "This may also take a little while to run. Not nearly as long as a full update did."
    msfupdate
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
cleanup(){
    if ask "Clean up?" Y; then
        apt-get -y autoremove && apt-get -y clean
    fi
}

#Now we run
check_euid
if ask "Switch to bleeding edge?" Y; then
    bleeding_edge
fi

if ask "Update & upgrade Kali Linux?" Y; then
    update
fi

print_status "all installations and updates complete."
print_status "Stand for something, because if you don't, you'll fall for anything."
cleanup
exit 0
