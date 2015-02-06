# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "mokote/debian-7"
  config.vm.network "private_network", ip: "192.168.10.10"
  config.vm.hostname = "godsbox"
#  config.vm.synced_folder "www", "/vagrant-www", type: "rsync", rsync__exclude: ".git/"
  config.vm.synced_folder "www", "/vagrant-www", type: "nfs"

  # Forwarded ports
  config.vm.network "forwarded_port", guest: 80, host: 8000
  config.vm.network "forwarded_port", guest: 3306, host: 33060

  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
    v.cpus = 2
  end

  # Provisioning Script
  # --------------------
  config.vm.provision "shell", path: "init.sh"

end
