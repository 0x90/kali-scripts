#!/bin/bash
. ask.sh

ask "Do you want to install htshells?" Y || exit 3

git clone git://github.com/wireghoul/htshells.git /usr/share/htshells/

