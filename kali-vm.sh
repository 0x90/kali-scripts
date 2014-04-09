#!/bin/bash
. helper.sh
. kali-update.sh
. kali-post-install.sh

install_virtualboc(){
    echo >> /etc/apt/sources.list
    echo deb http://download.virtualbox.org/virtualbox/debian wheezy contrib >> /etc/apt/sources.list
    apt-get update && apt-get install virtualbox-4.3
}


# http://www.dmo.ca/blog/detecting-virtualization-on-linux/
detect_vm(){
    apt-get install virt-what

#VMWare
dmidecode | awk '/VMware Virtual Platform/ {print $3,$4,$5}'
Run lspci and check for the string 'VirtualBox'.
You could run lspci | grep VirtualBox.
You could also run lsusb and check the string 'VirtualBox'. Such as lsusb | grep VirtualBox.
Also dmesg works, run dmesg | grep VirtualBox or dmesg | grep virtual.
}

check_vt(){
    apt-get update
    apt-get install msr-tools
    modprobe msr

    msr_vt=`rdmsr 0x3A`
    if [ "$msr_vt" = "1" ]; then
        return 0
    elif [ "$msr_vt" = "5" ]; then
        return 1
    else
        echo "Strange VT-D MSR value: $msr_vt"
        return 0
    fi
}

vmware_tools(){
    if ask "Do you want to install vmware-tools?" Y; then
        apt-get install -y xserver-xorg-input-vmmouse
        echo cups enabled >> /usr/bin/update-rc.d
        echo vmware-tools enabled >> /usr/bin/update-rc.d

        ln -s /usr/src/linux-headers-$(uname -r)/include/generated/uapi/linux/version.h /usr/src/linux-headers-$(uname -r)/include/linux/
        read -p "please choose 'install vmware tools' on your host and hit any key when done"
        echo

        mkdir /mnt/vmware
        mount /dev/cdrom /mnt/vmware
        tar zxpf /mnt/vmware/VMwareTools-*.tar.gz -C /tmp/
        /tmp/vmware-tools-distrib/vmware-install.pl default
        rm -rf /mnt/vmware
        rm -rf /tmp/vmware-*
    fi
}

parallels_tools(){
print_status "Mount Tools CD in virtual machine (Virtual Machine -> Install/Reinstall Parallels Tools)"
    pause

    # Download the patch from http://pastebin.com/8imsrmcN
    curl http://pastebin.com/raw.php?i=8imsrmcN > /tmp/parallels-tools-linux-3.12-prl-fs-9.0.23350.941886.patch

    # Make temporary copy of Parallels Tools, enter and patch it:
    #$ cp -R /media/$USER/Parallels\ Tools /tmp/
    #$ cd /tmp/Parallels\ Tools/kmods
    #$ tar -xaf prl_mod.tar.gz
    #$ patch -p1 -d prl_fs < parallels-tools-linux-3.12-prl-fs-9.0.23350.941886.patch
    #$ tar -czf prl_mod.tar.gz prl_eth prl_fs prl_fs_freeze prl_tg Makefile.kmods dkms.conf

    # Parallels 9 + Kali Linux 1.0.6 (kernel 3.12)
    mount -o exec /dev/hdb /media/Parallels\ Tools
    #cp -R /media/$USER/Parallels\ Tools /tmp/

    cp -R /media/cdrom0 /tmp/
    # cd /tmp/Parallels\ Tools/kmods
    cd /tmp/cdrom0/kmods

    # Patch from http://forum.parallels.com/showthread.php?294092-Fix-Patch-for-Parallel-Tools-9-0-23350-to-support-Linux-Kernel-3-12-%28Ubuntu-14-04%29
    tar -xaf prl_mod.tar.gz
    patch -p1 -d prl_fs < parallels-tools-linux-3.12-prl-fs-9.0.23350.941886.patch
    tar -czf prl_mod.tar.gz prl_eth prl_fs prl_fs_freeze prl_tg Makefile.kmods dkms.conf

    #4. Install normally:
    #$ sudo /tmp/Parallels\ Tools/install
    ../install
}

virtualbox_tools(){
    print_status "Installing VirtualBox Additions"
}

virtual_machine(){
    update
    development

    dmi=`dmidecode | awk '/VMware Virtual Platform/ {print $3}'`
    if [[ "$dmi" ==  *VMware* ]]; then
        if ask "It seems you're running kali as VMWare guest, do you want to install vmware-tools?" Y; then
            vmware_tools
        fi
    fi

}

virtual_machine


#!/bin/bash
# Parallels 9 + Kali Linux 1.0.6 (kernel 3.12)
#

echo "Preparing environment"
apt-get install -y gcc dkms make linux-headers-$(uname -r)

echo "Copying Parallels tools from CD"
cp -R /media/cdrom0 /tmp/

echo "Downloading patch file"
wget http://pastebin.com/raw.php?i=17fVAntV -O /tmp/parallels-tools-linux-3.12-prl-fs-9.0.23350.941886.patch

echo "Patching...."
cd /tmp/cdrom0/kmods
tar -xaf prl_mod.tar.gz
patch -p1 -d prl_fs < /tmp/parallels-tools-linux-3.12-prl-fs-9.0.23350.941886.patch
tar -czf prl_mod.tar.gz prl_eth prl_fs prl_fs_freeze prl_tg Makefile.kmods dkms.conf

echo "Launching install"
/tmp/cdrom0/install

