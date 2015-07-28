#!/usr/bin/env bash
#
# Automatic installation script.
#

. desktop.sh
. dev.sh
. embedded.sh
. hardware.sh
. helper.sh
. internet.sh
. pentest.sh
. phone.sh
. postinstall.sh
. video.sh
. vm.sh
. wireless.sh

ASKMODE="AUTO"

postinstall

install_vm
install_internet
install_dev
install_pentest
install_embedded
install_wireless
install_hardware
#install_desktop
#install_video
