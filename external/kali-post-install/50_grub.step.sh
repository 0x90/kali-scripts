#!/bin/bash
. ask.sh

ask "Do you want to change the grub default timeout to 0 sec?" Y || exit 3

sed -i -e "s,^GRUB_TIMEOUT=.*,GRUB_TIMEOUT=0," /etc/default/grub
echo "GRUB_HIDDEN_TIMEOUT=0" >> /etc/default/grub
echo "GRUB_HIDDEN_TIMEOUT_QUIET=true" >> /etc/default/grub

update-grub
