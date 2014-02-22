#!/bin/bash
#Description: Script to remove all logs and anything potentially legally binding
#Authors: Awk, Sed
#Company: Pwnie Express
#Date: March 1 2013
#Rev: 1.1

CAPTURE_FILES=("/opt/pwnpad/captures/*.cap"
  "/opt/pwnpad/captures/*.log"
  "/opt/pwnpad/captures/besside-ng/*"
  "/opt/pwnpad/captures/tshark/*"
  "/opt/pwnpad/captures/tcpdump/*"
  "/opt/pwnpad/captures/ettercap/*"
  "/opt/pwnpad/captures/sslstrip/*"
  "/opt/pwnpad/captures/bluetooth/*"
  "/opt/pwnpad/captures/evilap/*"
  "/opt/pwnpad/captures/nmap/*"
  "/opt/pwnpad/captures/cewl/*"
  "/opt/pwnpad/captures/wifite/*"
  "/opt/pwnpad/captures/sniffed/*"
  "/opt/pwnpad/captures/wsorrow/*"
  "/opt/pwnpad/captures/theharvester/*"
  "/opt/pwnpad/captures/stringswatch/*")

MISC_FILES=("/opt/pwnpad/easy-creds/easy-creds-*"
  "/opt/pwnpad/easycreds/*.txt"
  "/opt/pwnpad/captures/kismet/Kismet-*"
  "/opt/pwnpad/captures/cracked.txt"
  "/opt/pwnpad/captures/hs/")

set_choosewisely(){
  echo '
  This script will remove ALL LOGS and CAPTURES are you sure you want to continue?

  1. Yes
  2. No

  '
  read -p "Choice: " choosewisely
}

set_clearhistory(){
  echo '
  Would you like to remove Bash history as well?

  1. Yes
  2. No

  '
  read -p "Choice: " clearhistory
}

clear_capture_files(){
  echo 'Removing logs and captures from /opt/pwnpad/captures/

  '
  for file in "${CAPTURE_FILES[@]}"
  do
    echo "  Removing $file"
    wipe -f -i -r $file
  done
}

clear_misc_files(){
  echo 'Removing miscelaneous caps and logs / handshakes from other folders

  '
  for file in "${MISC_FILES[@]}"
  do
    echo "  Removing $file"
    wipe -f -i -r $file
  done
}

clear_tmp_files(){
  echo 'Removing all files from /tmp/

  '
  wipe -f -i -r /tmp/*
}

clear_all_files(){
  clear_capture_files
  clear_misc_files
  clear_tmp_files
}

clear_bash_history(){
                echo '
      Clearing bash history...
    '
                rm -r /root/.bash_history
}

initialize(){
  clear
  set_choosewisely
  set_clearhistory

  if [ $choosewisely -eq 1 ]
   then
    clear

    clear_all_files

    if [ $clearhistory -eq 1 ]
     then    
      clear_bash_history
      clear
      echo "
  
        Congratulations all your logs, captures, and bash history have been cleared!
  
        Unless of course you forgot about something else this script didn't know about...
       "

     else

      clear
      echo "
                      Not clearing bash history today
                
                Congratulations all your logs and captures have been cleared!
                
                Unless of course you forgot about something else this script didn't know about...
               "
     fi

  else
    clear
    echo "
     Your logs, captures, and bash history have been left alone.
     Have a nice day ^_^
    "
  fi
}

initialize
