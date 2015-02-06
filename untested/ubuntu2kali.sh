#!/bin/sh
# TODO: Test both variants
# http://ziolity.blogspot.ru/2012/04/ubuntu-1110-how-to-install-ruby.html

sudo add-apt-repository ppa:wagungs/kali-linux
sudo add-apt-repository ppa:wagungs/kali-linux1
sudo add-apt-repository ppa:wagungs/kali-linux2

sudo apt-get update -y && sudo apt-get upgrade -y

# If you don't want add kali linux ppa,
# you can add kali linux repository to your /etc/apt/sources.list

# For Ubuntu 12.04 Precise Pangoline
deb http://ppa.launchpad.net/wagungs/kali-linux/ubuntu precise main
deb http://ppa.launchpad.net/wagungs/kali-linux1/ubuntu precise main
deb http://ppa.launchpad.net/wagungs/kali-linux2/ubuntu precise main

# For Ubuntu 12.10 Quantal Quetzal
deb http://ppa.launchpad.net/wagungs/kali-linux/ubuntu quantal main
deb http://ppa.launchpad.net/wagungs/kali-linux1/ubuntu quantal main
deb http://ppa.launchpad.net/wagungs/kali-linux2/ubuntu quantal main

# For Ubuntu 13.04 Raring Ringtail
deb http://ppa.launchpad.net/wagungs/kali-linux/ubuntu raring main
deb http://ppa.launchpad.net/wagungs/kali-linux1/ubuntu raring main
deb http://ppa.launchpad.net/wagungs/kali-linux2/ubuntu raring main

# And then add this key
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 8FDFDB57

# Update and upgrade your Ubuntu
sudo apt-get update && sudo apt-get upgrade && sudo apt-get dist-upgrade
