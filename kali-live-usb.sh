#!/bin/sh

dd if=kali.iso of=/dev/sdb bs=512k

# Добавление возможности постоянного сохранения (Persistence) к вашим Kali Live USB
gparted /dev/sdb
mkdir /mnt/usb
mount /dev/sdb2 /mnt/usb
echo "/ union" >> /mnt/usb/persistence.conf
umount /mnt/usb
