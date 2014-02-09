#!/bin/bash
#===========================
# WATOBO-Installer for Linux
#---------------------------
# Tested on BackTrack 5R2
#===========================
# Date: 06.08.2012
# Author: Andreas Schmidt
Version=1.1
#---
# Version 1.1
# added libnetfilter-queue-dev package & gem
# added platform detection
#---

info() {
  printf "\033[36m$*\033[0m\n"
}

head() {
  printf "\033[31m$*\033[0m\n"
}

head "##############################################"
head "#     W A T O B O - I N S T A L L E R        #"
head "##############################################"
info "Version: $Version"
gem_opts=""
platform="Generic"
file=/etc/issue
if grep -q "BackTrack" $file
then
 platform="BackTrack"
 gem_opts="--user-install"
fi

info "Platform: $platform"

if [ "$platform" == "BackTrack" ]
then
echo "Adding /root/.gem/ruby/1.9.2/bin/ to your PATH .."
echo 'export PATH=$PATH:/root/.gem/ruby/1.9.2/bin' >> /root/.bashrc
export PATH=$PATH:/root/.gem/ruby/1.9.2/bin
#. /root/.bashrc
fi

echo "Installing required gems ..."
for G in ffi multi_json childprocess selenium-webdriver mechanize fxruby net-http-digest_auth net-http-persistent nokogiri domain_name unf webrobots ntlm-http net-http-pipeline nfqueue watobo
do
  info ">> $G"
  gem install $gem_opts $G
done

echo "Install libnetfilter for transparent proxy mode"
apt-get install libnetfilter-queue-dev

info "Installation finished."
echo "Open a new shell and type watobo_gui.rb to start WATOBO."
echo "For manuals/videos and general information about WATOBO please check:"
echo "* http://watobo.sourceforge.net/"

