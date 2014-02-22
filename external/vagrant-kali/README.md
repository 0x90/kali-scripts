# Kali Linux  

Pre-configured Kali linux VirtualBox VM. VirtualBox VM will be converted into a vagrant box that can be added to your vagrant library.

## Pre-requisites  

* [Vagrant](http://www.vagrantup.com/)  
* [Packer] (http://packer.io)  
* [VirtualBox](https://www.virtualbox.org/)  

## Bring in submodules

	git submodule init  
	git submodule update  

## Vagrant base box

If you don't already have the vagrant box in your library, you can create this one of two ways.  You can use the packer submodule of the [packer-boxes](https://github.com/SocialGeeks/packer-boxes) repository to create the base box with packer.

	cd packer/kali-linux-105-amd64
	packer build template.json   
	vagrant box remove kali virtualbox  
	vagrant box add kali packer_virtualbox_virtualbox.box  

You can also download the [packer-boxes](https://github.com/SocialGeeks/packer-boxes) repository and [follow the instructions](https://github.com/SocialGeeks/packer-boxes/blob/master/README.md) to create vagrant base boxes and add them to your library.  

## Start kali with vagrant  

The 'vagrant up' command will import the kali base image into VirtualBox and then run the post configuration specified in the Vagrantfile.  Use 'vagrant ssh' to ssh into kali.  XForwarding is configured and working.  The Vagrantfile will open the VirtualBox console in full screen.  You can login with root/toor.

	vagrant up  

