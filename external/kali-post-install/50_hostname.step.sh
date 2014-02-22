#!/bin/bash
. ask.sh

ask "Do you want a different hostname on every boot?" N || exit 3

grep -q "hostname" /etc/rc.local hostname || sed -i 's#^exit 0#hostname $(cat /dev/urandom | tr -dc "A-Za-z" | head -c8)\nexit 0#' /etc/rc.local
