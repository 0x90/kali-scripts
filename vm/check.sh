#!/usr/bin/env bash


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