# Kali scripts

Welcome to kali-scripts repository, which is created to help managing Kali Linux software installation.
Scripts are in development at the moment, so many bugs are present.
Please review code before launching. Feel free to commit bugs/patches.

## Contents

This scripts are pretended to be used to automate installation or deployment of Kali Linux.
Every script can be launched separately except helper.sh which us just a functions storage file.

    autoinstall.sh - install ALL in AUTO mode
    desktop.sh - desktop environment installation and postinstall configuration (Gnome, XFCE, KDE)
    dev.sh - developer tools (GCC, Python, Ruby)
    embedded.sh - embedded developer toolchains (MIPS, ARM)
    hardware.sh - stuff to deal with hardware (Arduino, OLS, Sigrok)
    helper.sh - misc helpful functions
    internet.sh - browsers (Chrome, Firefox, Chromium) and IM (Jabber, Skype)
    phone.sh - tools for communication with mobile phones (iOS, Android)
    pentest.sh - pentest tools installation script (MITMf,)
    postinstall.sh - common software installation and configuration (SSH, GDM, MSF, PostgreSQL)
    video.sh - video drivers installation script (Nvidia, AMD)
    vm.sh - script to install vm hypervisors or vm tools (VirtualBox, VMWare, Parallels)
    wireless.sh - wireless stuff (WiFi, Bluetooth, SDR)

## Makefile

New version of Kali scripts is beeing developeb. Try it!
```
make
make dev-mini
```

## Docker

Docker build examople:
```
docker build --squash --rm -t . 
```

## TODO

Ideas and plans, things todo:
- Check everything to work under Kali 2018.1
- Check everything to work under Parrot
- Migrate from scripts to Makefile
- Use wifi-arsenal, sdr-arsenal, bluetooth-arsenal....
- Dockerfile with kali-scripts
- Vagrantfile  with kali-scripts


https://www.offensive-security.com/kali-linux/top-10-post-install-tips/
