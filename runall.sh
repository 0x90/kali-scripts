#!/usr/bin/env bash
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

parse_args
echo "ASKMODE: ${ASKMODE}"
ASKMODE="AUTO"
echo "ASKMODE: ${ASKMODE}"
postinstall

install_vm
#install_desktop
install_internet
install_dev_tools
install_pentest_tools
install_embedded
install_wireless
install_hardware