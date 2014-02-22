#!/bin/bash

# add bleeding adge repo
out=`grep  "kali-bleeding-edge" /etc/apt/sources.list`
if [[ "$out" !=  *kali-bleeding-edge* ]]; then
  echo "# bleeding edge repository" >> /etc/apt/sources.list
  echo "deb http://repo.kali.org/kali kali-bleeding-edge main" >> /etc/apt/sources.list
  
  echo "deb http://http.kali.org/kali kali main non-free contrib" >> /etc/apt/sources.list
  echo "deb http://security.kali.org/kali-security kali/updates main contrib non-free" >> /etc/apt/sources.listi
fi

# update repository
apt-get update && apt-get upgrade
apt-get -y dist-upgrade --fix-missing
