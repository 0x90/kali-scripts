#!/bin/bash
# Kali Linux additional tools and tweaks installation script
# author: @090h
# Respect: g0tmilk, darkoperator
# Greetz fly to: DSecRG, Justin Bieber's Fan Club
########################################################################################################################

. helper.sh
. kali-embedded.sh
. kali-kernel.sh
. kali-mirror.sh
. kali-post-install.sh
. kali-pentest.sh
. kali-tweaks.sh
. kali-update.sh
. kali-vm.sh
. kali-wipe.sh


# All soft installation & config
all(){
    bleeding_edge
    development
    install_packages
    tweak
    xfce
    wipe
}

#This function shows which switches are needed to run the script.
usage(){
	echo "Use one or more of the following switches:"
	echo ""
	echo "   -A - Install and config everything"
	echo "   -b - Switch to bleeding edge"
	echo "   -c - Cleanup"
	echo "   -d - Install packages for development"
	echo "   -e - Install embedded tools (ARM, MIPS)"
	echo "   -g - GNOME tweaks"
	echo "   -h - see this message"
	echo "   -k - Kernel work"
	echo "   -l - build Kali live"
	echo "   -m - create Kali mirror"
    echo "   -p - Run post install"
	echo "   -t - Tweak Kali Linux"
	echo "   -u - Upgrade packages"
	echo "   -v - Install tools fot virtual environmanet (VMWare, VirtualBox, Parallels)"
	echo "   -w - wipe all logs"
	echo "   -x - XFCE installation"
}

####################################### BEGIN MAIN SCRIPT ##########################################
(($# )) || usage


#This is the main logic calling the proper functions based on the switches used.
while getopts "Abcdeghklmptuvwx" flag
do
	if [ "$flag" = "A" ]; then
        all
    elif [ "$flag" = "b" ]; then
        bleeding_edge
    elif [ "$flag" = "c" ]; then
        cleanup
    elif [ "$flag" = "d" ]; then
        install_devel
    elif [ "$flag" = "e" ]; then
        install_embedded
    elif [ "$flag" = "g" ]; then
        gnome
    elif [ "$flag" = "h" ]; then
        usage
    elif [ "$flag" = "k" ]; then
        kernel
    elif [ "$flag" = "l" ]; then
        live
    elif [ "$flag" = "m" ]; then
  	    mirror
    elif [ "$flag" = "p" ]; then
  	    install_packages
  	elif [ "$flag" = "t" ]; then
  	    tweak
  	elif [ "$flag" = "u" ]; then
  	    update
  	elif [ "$flag" = "v" ]; then
  	    virtual_machine
  	elif [ "$flag" = "w" ]; then
  	    wipe
  	elif [ "$flag" = "x" ]; then
  	    xfce
    else
  	    usage
  	    exit 0
    fi
done

# Cleanup
#print_status "All installations and updates complete!"
# Reboot
# ask "Do you want to reboot?" N && reboot
