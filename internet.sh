#!/usr/bin/env bash
# Browsers, TOR and IM
. helper.sh

install_chrome(){
    print_status "Adding Google Chrome to APT..."
#    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
#    echo "deb http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
#    apt-get update -y && apt-get install google-chrome-stable -y
    apt_add_key "https://dl-ssl.google.com/linux/linux_signing_key.pub"
#    apt_add_sources "deb http://dl.google.com/linux/chrome/deb/ stable main" "google-chrome"
    apt_add_source  "google-chrome"
    apt-get install google-chrome-stable -y

    print_status "Patching Google Chrome to run as root.."
    cp /usr/bin/google-chrome /usr/bin/google-chrome.old && sed -i 's/^\(exec.*\)$/\1 --user-data-dir/' /usr/bin/google-chrome
}

install_chromium(){
    apt-get install -y chromium
    echo "# simply override settings above" >> /etc/chromium/default
    echo 'CHROMIUM_FLAGS="--password-store=detect --user-data-dir"' >> /etc/chromium/default
}

install_firefox(){
    apt-get remove iceweasel
    apt_add_source  "ubuntuzilla"
#    echo "deb http://downloads.sourceforge.net/project/ubuntuzilla/mozilla/apt all main" > /etc/apt/sources.list.d/ubuntuzilla.list
    apt-key adv --recv-keys --keyserver keyserver.ubuntu.com C1289A29
    apt-get update -y && apt-get install firefox-mozilla-build -y
}

install_browsers(){
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

install_skype(){
    dpkg --add-architecture i386 && apt-get update -y

    cd /tmp
    wget -O skype-install.deb http://www.skype.com/go/getskype-linux-deb
    dpkg -i skype-install.deb
    apt-get -f install

    apt-get install -y gdebi
#    apt-get -f install
    apt-get autoclean
}

install_tor(){
    apt-get install tor vidalia privoxy -y
    echo forward-socks4a / 127.0.0.1:9050 . >> /etc/privoxy/config

    mkdir -p /var/run/tor
    chown debian-tor:debian-tor /var/run/tor
    chmod 02750 /var/run/tor

#    /etc/init.d/tor start
#    /etc/init.d/privoxy start
    #USE SOCKS PROXY 127.0.0.1:9059
}

install_internet(){
    if ask "Do you want to install some browsers (Chrome, Firefox, OWASP Mantra)?" N; then
        install_browsers
    fi

    if ask "Do you want to install TOR?" N; then
        install_tor
    fi

    if ask "Do you want to install Skype?" N; then
        install_skype
    fi

    if ask "Do you want to install pidgin and an OTR chat plugin?" N; then
        apt-get -y install pidgin pidgin-otr
    fi

    if ask "Install Dropbox? " N; then
        apt-get install -y nautilus-dropbox
    fi
}

if [ "${0##*/}" = "internet.sh" ]; then
    install_internet
fi