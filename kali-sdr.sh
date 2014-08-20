#!/bin/bash
. helper.sh

### RTFM
# http://labs.inguardians.com/
# http://nutaq.com/en/blog/complete-model-based-pc-fpga-sdr-development-environment-gnu-radio
# http://funoverip.net/2014/07/gnu-radio-cc1111-packets-encoderdecoder-blocks/
# http://leetupload.com/blagosphere/index.php/2014/03/28/analyze-and-crack-gsm-downlink-with-a-usrp/
# http://g4akw.blogspot.ru/
# http://eliasoenal.com/

# http://www.kubonweb.de/?tag=rtl-sdr

# https://raw.githubusercontent.com/zacinaction/kicksat-groundstation/master/Install-SpriteRadio

# IEEE 802.11
# https://www.ruby-forum.com/topic/4487026
cd /tmp
git clone git://github.com/bastibl/gr-ieee802-11.git
cd gr-ieee802-11
mkdir build
cd build
cmake ..
make
make install
cd /tmp
rm -rf /tmp/gr-ieee802-11

# Digital speech decoder
git clone https://github.com/LinuxSheeple-E/dsd
cd dsd
git checkout Feature/DMRECC
cd dsd
mkdir build
cd build
cmake ..
make


### BladeRF
# https://github.com/Nuand/bladeRF
# https://github.com/jmichelp/sdrsharp-bladerf


### DVB
# https://github.com/drmpeg/gr-dvbs
# https://github.com/BogdanDIA/gr-dvbt
# https://github.com/drmpeg/gr-dvbs2

### Digital Speech Decode
# https://github.com/argilo/gr-dsd
# https://github.com/EliasOenal/multimon-ng
# https://github.com/LinuxSheeple-E/dsd

### GPS
# https://github.com/davidhodo/gnuradio_gps

### 802.1X 
# https://github.com/bastibl/gr-ieee802-11
# https://github.com/bastibl/gr-ieee802-15-4
# https://github.com/wishi/gr_802.15.4
# https://github.com/UpYou/gr-ieee802-15-5
# https://github.com/septikus/gnuradio-802.15.4-demodulation
# https://code.google.com/p/zigbee-security


### MOBILE NETWORKS ###
# git://git.osmocom.org/gr-osmosdr)
# https://github.com/anastas/gr-cdma
# https://github.com/ptrkrysik/gr-gsm
# https://github.com/scateu/airprobe-3.7-hackrf-patch
# https://github.com/oWCTejLVlFyNztcBnOoh/gr-lte
# https://github.com/NightlyDev/Airprobe-GSM-RCV-GR3.7
# http://sourceforge.net/projects/openbts
# https://github.com/neo4reo/OpenLTE
# http://sourceforge.net/projects/openlte/
# https://github.com/kit-cel/gr-lte
# https://github.com/libLTE/libLTE
# https://github.com/Evrytania/LTE-Cell-Scanner
# https://github.com/JiaoXianjun/rtl-sdr-LTE
# https://github.com/snailpy/ltetoolkit
# https://github.com/tinkerbeast/understanding-lte-in-python

# Code for using GNURadio w/ a USRP
# https://github.com/edwatt/REU2014

##### Blocks
# https://github.com/guruofquality/grex
# https://github.com/guruofquality/grextras
# https://github.com/bistromath/gr-ais
# https://github.com/dl1ksv/gr-display
# https://github.com/fewu/gnuradio_drm
# https://github.com/argilo/gr-qam
# https://github.com/osh/gr-bitcoin
# https://github.com/bistromath/gr-air-modes
# https://github.com/mogar/uhd_ofdm
# https://github.com/glneo/gr-clicker
# https://github.com/scateu/gr-remotecar
# https://github.com/dl1ksv/gr-ax25
# https://github.com/bastibl/gr-rds
# https://github.com/argilo/gr-ham

#### Misc
# https://github.com/azorg/gnuradio-examples
# https://github.com/UpYou/gnuradio-tools
# https://github.com/bistromath/gr-scanner
# https://github.com/n-west/gr-west
# https://github.com/urbank/beacon
# https://github.com/piratfm/gr-ssrptx
# https://github.com/argilo/sdr-examples

### Tools
# https://github.com/argilo/ham-utils
# 
