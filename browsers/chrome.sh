#!/usr/bin/env bash
#
source ../helper/helper.sh

install_chrome(){
    echo "Adding Google Chrome to APT..."
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
    apt-get update -y && apt-get install google-chrome-stable -y

    echo "Patching Google Chrome to run as root.."
    # http://www.youtube.com/watch?v=FWyZrazU3uw
    cp /usr/bin/google-chrome /usr/bin/google-chrome.old && sed -i 's/^\(exec.*\)$/\1 --user-data-dir/' /usr/bin/google-chrome
}