#!/bin/bash
. ask.sh

ask "Do you want to install the buffer-overvlow-kit? (requires ruby)" Y || exit 3

mkdir ~/develop
cd ~/develop
git clone https://github.com/KINGSABRI/BufferOverflow-Kit.git
