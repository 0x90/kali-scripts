#!/usr/bin/env bash

print_status(){
    echo -e "\x1B[01;34m[*]\x1B[0m $1"
}

print_good(){
    echo -e "\x1B[01;32m[*]\x1B[0m $1"
}

print_error(){
    echo -e "\x1B[01;31m[*]\x1B[0m $1"
}

print_notification(){
	echo -e "\x1B[01;33m[*]\x1B[0m $1"
}

apt_upgrade(){
    apt-get update && apt-get upgrade -y
}

apt_super_upgrade(){
    apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y
}

apt_cleanup(){
    apt-get -y autoremove && apt-get -y clean
}

install_add_apt_repo(){
    cp files/bin/add-apt-repository.sh /usr/sbin/add-apt-repository
    chmod o+x /usr/sbin/add-apt-repository
}

apt_echo_sources(){
    echo "$1" > "/etc/apt/sources.list.d/$2.list"
}

apt_add_source(){
    cp -f "files/etc/$1.list" "/etc/apt/sources.list.d/$1.list" && apt-get update -y
}

apt_add_repo(){
    if [ ! -f /usr/sbin/add-apt-repository ]; then
        print_notification "File /usr/sbin/add-apt-repository not found! Installing..."
        install_add_apt_repo
    fi
    add-apt-repository "$1" && apt-get update -y
}

apt_add_key(){
    wget -q "$1" -O- | sudo apt-key add -
}

check_euid(){
#    print_status "Checking for root privs."
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be ran with sudo or root privileges, or this isn't going to work."
	    exit 1
#    else
#        print_good "w00t w00t we are root!"
    fi
}

command_exists() {
    type "$1" &> /dev/null ;
}

check_success(){
    if [ $? -eq 0 ]; then
        print_good "Procedure successful."
    else
        print_error "Procedure unsucessful! Exiting..."
        exit 1
    fi
}

ask(){
    if [ "$ASKMODE" = "WIZARD" ]; then
        while true; do
            if [ "${2:-}" = "Y" ]; then
                prompt="Y/n"
                default=Y
            elif [ "${2:-}" = "N" ]; then
                prompt="y/N"
                default=N
            else
                prompt="y/n"
                default=
            fi

            read -p "$1 [$prompt] " REPLY
            if [ -z "$REPLY" ]; then
                REPLY=${default}
            fi

            case "$REPLY" in
                Y*|y*) return 0 ;;
                N*|n*) return 1 ;;
            esac
        done
    elif [ "$ASKMODE" = "YES" ]; then
        return 1;
    elif [ "$ASKMODE" = "NO" ]; then
        return 0;
    elif [ "$ASKMODE" = "AUTO" ]; then
        case "$default" in
                Y*|y*) return 0 ;;
                N*|n*) return 1 ;;
        esac
    fi
}

pause(){
   read -sn 1 -p "Press any key to continue..."
}

read_default(){
    return read -e -p "$1" -i "$2"
}

write_with_backup(){
    if [ -f $2 ]; then
        print_notification "$2 found, backuping to $2.bak"
        cp "$2" "$2.bak"
    fi
    cp -f "$1" "$2"

}

show_help(){
    echo "Usage: cmd [-h] [-y] [-n] [-a] [-u]"
    echo "-h - help message"
    echo "-y - yes to all dialog questions"
    echo "-n - no to all questions"
    echo "-a - auto mode: choose default"
    echo "-u - update scripts"
}

# Main
ASKMODE="WIZARD"
while getopts ":ahnuyv" opt; do
    case ${opt} in
        h|\?) show_help;;
        a) ASKMODE="AUTO";;
        n) ASKMODE="NO";;
        y) ASKMODE="YES";;
        u) git pull;;
        v) verbose=1;;
    esac
done

check_euid
