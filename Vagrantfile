# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"
  config.vm.network :public_network
  config.omnibus.chef_version = :latest

  config.vm.provider :aws do |aws, override|
    override.vm.box = "dummy"
    override.vm.box_url = "https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
    override.ssh.username = "ubuntu"
    override.ssh.private_key_path = "#{ENV["HOME"]}/.ssh/default_ssh.id"
    aws.endpoint = "https://api.greenqloud.com/" # trailing slash!
    aws.access_key_id = ENV["EC2_ACCESS_KEY"]
    aws.secret_access_key = ENV["EC2_SECRET_KEY"]
    aws.instance_type = "t1.micro"
    aws.ami = "qmi-b58041dd" # Ubuntu Precise
    aws.keypair_name = "default"
  end

  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = %w{cookbooks site-cookbooks}
    chef.add_recipe "ntp"
    chef.add_recipe "timezone"
    chef.add_recipe "tcpcrypt"
    chef.add_recipe "dnscrypt-proxy"
    chef.add_recipe "btsync"
    chef.add_recipe "gnupg2"
    chef.add_recipe "tarsnap"
    chef.add_recipe "apache2"
    chef.add_recipe "apache2::mod_dav_fs"

    chef.json = {
      "apache" => {
        "listen_ports" => ["80", "443"]
      }
    }
  end
end
