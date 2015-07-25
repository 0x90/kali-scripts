#!/usr/bin/env bash
. print.sh

check_euid(){
    print_status "Checking for root privs."
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be ran with sudo or root privileges, or this isn't going to work."
	    exit 1
#    else
#        print_good "w00t w00t we are root!"
    fi
}

command_exists () {
    type "$1" &> /dev/null ;
}


check_success(){
    if [ $? -eq 0 ]; then
        print_good "Procedure successful."
    else
        print_error "Procedure unsucessful! check $logfile for details. Bailing."
        exit 1
    fi
}