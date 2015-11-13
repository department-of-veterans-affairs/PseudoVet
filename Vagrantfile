# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "hashicorp/precise32"
  config.vm.network "public_network"
  # config.vm.network "forwarded_port", guest: 443, host: 8081
  
  config.vm.provider :virtualbox do |vb|
      vb.name = "pseudovet"
  end
  
  config.vm.provision :shell, path: "provision/setup-deb.sh"
  
  #  config.vm.provision "chef_zero" do |chef|
  #    # Specify the local paths where Chef data is stored
  #    chef.cookbooks_path = "cookbooks"
  #    chef.data_bags_path = "data_bags"
  #    chef.roles_path = "roles"  
  #    # chef.add_recipe "apache2"
  #  end
end
