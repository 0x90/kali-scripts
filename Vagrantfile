# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "kali"

  config.vm.provider :virtualbox do |vb|
    # Use VBoxManage to customize the VM. For example to change memory:
    vb.customize ["modifyvm", :id, "--memory", "2048"]

    # vb.customize ["modifyvm", :id, "--cpuexecutioncap", "65"]
    vb.gui = true
  end

  config.vm.provider "vmware_fusion" do |vmf, override|
    vmf.vmx["memsize"] = "2048"
    # vmf.vmx["numvcpus"] = "2"
    vmf.gui = true
  end

  kali.vm.provider "vmware_workstation" do |vmw|
      vmw.gui = true
    end

    kali.vm.provider "vmware_desktop" do |vmd|
      vmd.gui = true
    end

    kali.vm.provider :parallels do |parallels|
      parallels.gui = true
    end

    kali.vm.provider "docker" do |docker|
      docker.name = 'kali'
    end
  end

  config.ssh.forward_x11 = true
  # config.vm.provision "shell", path: "autoinstall.sh"
end