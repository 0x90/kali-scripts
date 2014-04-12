#!/bin/bash
. helper.sh

install_bluetooth(){
    print_status "Installing dependencies for BlueMaho"
    apt-get install anyremote redfang spooftooph python-bluez  kismet-plugins obexfs ubertooth bluepot bluewho btscanner
    apt-get install libopenobex1:i386 libopenobex1-dev:i386 libbluetooth-dev:i386

    wget "https://wiki.thc.org/BlueMaho?action=AttachFile&do=get&target=bluemaho_v090417.tgz"

}

if ask "Install bluetooth hacking tools?" Y; then
    install_bluetooth
fi