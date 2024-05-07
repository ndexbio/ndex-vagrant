# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  config.vm.box = "rockylinux/8"
  config.vm.provision :shell, path: "bootstrap.sh"
  config.ssh.forward_x11 = true  
  config.vm.network "forwarded_port", guest: 80, host: 8081
  config.vm.network "forwarded_port", guest: 8080, host: 8080 
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "6144"
    vb.cpus = "1"
  end
end
