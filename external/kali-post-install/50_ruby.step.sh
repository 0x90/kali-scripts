#!/bin/bash
. ask.sh

ask "Do you want to install ruby and extras?" Y || exit 3

cp dotfiles/.gemrc ~/.gemrc

apt-get -y install ruby-full ruby-dev libpcap-ruby libpcap-dev libsp-gxmlcpp-dev libsp-gxmlcpp1 libxslt1.1 libxslt1-dev
update-alternatives --config ruby

gem install pry colorize mechanize pcaprub nokogiri 
