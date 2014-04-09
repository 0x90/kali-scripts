#!/bin/bash
# Based on http://security-is-just-an-illusion.blogspot.ru/2013/04/security-is-just-illusion-os-dev-build.html
. helper.sh


# Build custom Kali ISO
live(){
    #Set up the build environment.
    apt-get install git live-build cdebootstrap kali-archive-keyring
    git clone git://git.kali.org/live-build-config.git
    cd live-build-config
    lb config
    lb build


    # Configuring the Kali ISO Build In the official documentation,
    # this step is optional, but this is where you have to choose the desktop
    # environment you wish to use for the build.
    # The file to modify is kali.list.chroot in the config/package-lists
    cd config/package-lists
    nano -w kali.list.chroot
    #nano live-build-config\config\package-lists\kali.list.chroot

    # Get arch and build the ISO
    lb config --architecture i386
    lb build

    #TODO: add some code here
    # Fetch the latest Kali debootstrap script from git
    curl "http://git.kali.org/gitweb/?p=packages/debootstrap.git;a=blob_plain;f=scripts/kali;hb=HEAD" > kali-debootstrap &&\
    sudo debootstrap kali
    ./kali-root http://http.kali.org/kali

    # Build Kali Latest
    ./kali-debootstrap && sudo tar -C kali-root -c . | sudo docker import - linux/kali &&\
    rm -rf ./kali-root && docker run -t -i linux/kali cat /etc/debian_version &&\
    echo "Build OK" || echo "Build failed!"



    # OS X
    diskutil list
    diskutil unmountDisk /dev/disk1
    #Now we can continue in accordance with the instructions above
    # (but use bs=8192 if you are using the OS X dd, the number comes from 1024*8).
    dd if=image.iso of=/dev/disk1 bs=8192
    dd if=kali.iso of=/dev/sdb bs=512k
    diskutil eject /dev/disk1

    # Добавление возможности постоянного сохранения (Persistence) к вашим Kali Live USB
    gparted /dev/sdb
    mkdir /mnt/usb
    mount /dev/sdb2 /mnt/usb
    echo "/ union" >> /mnt/usb/persistence.conf
    umount /mnt/usb
}

#OR BUILD YOUR OWN CUSTOM ISO.
apt-get install git live-build cdebootstrap
git clone git://git.kali.org/live-build-config.git
cd live-build-config
lb config
lb build


####

dd if=kali.iso of=/dev/sdb bs=512k

# Добавление возможности постоянного сохранения (Persistence) к вашим Kali Live USB
gparted /dev/sdb
mkdir /mnt/usb
mount /dev/sdb2 /mnt/usb
echo "/ union" >> /mnt/usb/persistence.conf
umount /mnt/usb
