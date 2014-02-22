#!/bin/bash
. ask.sh

ask "Do you want to install meld (graphical diff tool)?" Y || exit 3

apt-get -y install meld
gconftool-2 --type bool --set /apps/meld/show_line_numbers true
gconftool-2 --type bool --set /apps/meld/show_whitespace true
gconftool-2 --type bool --set /apps/meld/use_syntax_highlighting true
gconftool-2 --type int --set /apps/meld/edit_wrap_lines 2

