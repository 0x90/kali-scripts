#!/bin/bash

. ask.sh

ask "Do you want to install some terminal changes and tweaks?" Y || exit 3

gconftool-2 --type bool --set /apps/gnome-terminal/profiles/Default/scrollback_unlimited true #Terminal -> Edit -> Profile Preferences -> Scrolling -> Scrollback: Unlimited -> Close
gconftool-2 --type string --set /apps/gnome-terminal/profiles/Default/background_darkness 0.85611499999999996 # Not working 100%!
gconftool-2 --type string --set /apps/gnome-terminal/profiles/Default/background_type transparent
