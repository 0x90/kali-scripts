#!/usr/bin/env bash
#
. helper.sh

install_chrome(){
    echo "Adding Google Chrome to APT..."
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
    echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
    apt-get update -y && apt-get install google-chrome-stable -y

    echo "Patching Google Chrome to run as root.."
    cp /usr/bin/google-chrome /usr/bin/google-chrome.old && sed -i 's/^\(exec.*\)$/\1 --user-data-dir/' /usr/bin/google-chrome
}

install_chromium(){
    apt-get install -y chromium
    echo "# simply override settings above" >> /etc/chromium/default
    echo 'CHROMIUM_FLAGS="--password-store=detect --user-data-dir"' >> /etc/chromium/default
}

install_firefox(){
#    apt-get remove iceweasel
    echo "deb http://downloads.sourceforge.net/project/ubuntuzilla/mozilla/apt all main" > /etc/apt/sources.list.d/ubuntuzilla.list
    apt-key adv --recv-keys --keyserver keyserver.ubuntu.com C1289A29
    apt-get update -y &&  apt-get install firefox-mozilla-build -y
}

install_browser(){
    if ask "Do you want to install Chromium (and allowing run as root) ?" Y; then
        install_chromium
    fi

    if ask "Do you want to install Google Chrome (and allowing run as root) ?" Y; then
        install_chrome
    fi

    if ask "Do you want to install Firefox?" Y; then
        install_firefox
    fi
    if ask "Do you want to install the Flash player?" Y; then
        apt-get -y install flashplugin-nonfree
    fi

    if ask "Do you want to install OWASP Mantra browser?" Y; then
        apt-get install -y owasp-mantra-ff
    fi
}
