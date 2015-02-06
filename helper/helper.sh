#!/bin/bash

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

read_default(){
    return read -e -p "$1" -i "$2"
}

success_check(){
    if [ $? -eq 0 ]; then
        print_good "Procedure successful."
    else
        print_error "Procedure unsucessful! check $logfile for details. Bailing."
        exit 1
    fi
}

ask(){
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
            REPLY=$default
        fi

        case "$REPLY" in
            Y*|y*) return 0 ;;
            N*|n*) return 1 ;;
        esac
    done
}

pause(){
   read -sn 1 -p "Press any key to continue..."
}

check_euid(){
    print_status "Checking for root privs."
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be ran with sudo or root privileges, or this isn't going to work."
	    exit 1
    else
        print_good "w00t w00t we are root!"
    fi
}

check_root(){
    print_status "Checking for root privs."
    if [ $(whoami) != "root" ]; then
        print_error "This script must be ran with sudo or root privileges, or this isn't going to work."
        exit 1
    else
        print_good "We are root."
    fi
}

cleanup(){
    if ask "Clean up?" Y; then
        apt-get -y autoremove && apt-get -y clean
    fi
}

update(){
    if ask "Step 0: Fresh the system?" Y; then
        apt-get update -y && apt-get upgrade -y
    fi
}
command_exists () {
    type "$1" &> /dev/null ;
}
