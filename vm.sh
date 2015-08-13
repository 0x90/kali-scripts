#!/usr/bin/env bash
. helper.sh

check_vt(){
    apt-get update && apt-get install msr-tools
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

install_virtualbox(){
    print_status "Add VirtualBox repo"
    apt_add_source "virtualbox"

    print_status "Trying to add Oracle VirtualBox key"
    apt_add_key "https://www.virtualbox.org/download/oracle_vbox.asc"

    apt-get update -y && apt-get install dkms -y && apt-get install virtualbox-4.3 -y
}

install_virtualbox_tools(){
    print_status "Installing Oracle VirtualBox tools"
}

install_vmware_tools(){
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
        rm -rf /mnt/vmware && rm -rf /tmp/vmware-*
    fi
}

install_parallels_tools(){
    # TODO: Fix it.
    # Parallels 9 + Kali Linux 1.0.6 (kernel 3.12)
#    print_status "Mount Tools CD in virtual machine (Virtual Machine -> Install/Reinstall Parallels Tools)"
#    pause
    print_status "Preparing environment"
    apt-get install -y gcc dkms make linux-headers-$(uname -r)

    print_status "Copying Parallels tools from CD"
    cp -R /media/cdrom0 /tmp/

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


install_vm_host(){
    # TODO: Check if VT is available
    if ask "Do you want to install VirtualBox?" N; then
        echo "Installing VirtualBox..."
        install_virtualbox
    fi

    if ask "Do you want to install QEMU?" N; then
        echo "Installing QEMU..."
        apt-get install qemu-system-arm qemu-system-mips qemu-system-common qemu-system-x86 qemu virt-manager virtinst -y
    fi
}

install_vm_tools(){
    # TODO: Get VM type
    dmi=`dmidecode | awk '/VMware Virtual Platform/ {print $3}'`
    if [[ "$dmi" ==  *VMware* ]]; then
        if ask "It seems you're running kali as VMWare guest, do you want to install vmware-tools?" Y; then
            install_vmware_tools
        fi
    fi

    install_virtualbox_tools
}

install_vm(){
    # # http://www.dmo.ca/blog/detecting-virtualization-on-linux/
    install_vm_tools


    install_vm_host
#    install_parallels_tools
#    apt-get install virt-what

#VMWare
#dmidecode | awk '/VMware Virtual Platform/ {print $3,$4,$5}'
#Run lspci and check for the string 'VirtualBox'.
#You could run lspci | grep VirtualBox.
#You could also run lsusb and check the string 'VirtualBox'. Such as lsusb | grep VirtualBox.
#Also dmesg works, run dmesg | grep VirtualBox or dmesg | grep virtual.
}

if [ "${0##*/}" = "vm.sh" ]; then
    install_vm
fi