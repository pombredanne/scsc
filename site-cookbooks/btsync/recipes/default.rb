include_recipe "apt"
include_recipe "folders"

apt_repository "btsync" do
  uri "http://ppa.launchpad.net/tuxpoldo/btsync/ubuntu"
  distribution node["lsb"]["codename"]
  components ["main"]
  keyserver "keyserver.ubuntu.com"
  key "D294A752"
end

execute "Preconfigure btsync" do
  command "echo btsync btsync/managed-configuration boolean false | debconf-set-selections"
end

package "btsync"

group node["btsync"]["group"] do
  action :create
end

user node["btsync"]["user"] do
  shell "/bin/false"
  gid node["btsync"]["group"]
  system true
  action :create
end

group "data" do
  action :modify
  members node["btsync"]["user"]
  append true
end

directory "/var/lib/btsync" do
  owner node["btsync"]["user"]
  group node["btsync"]["group"]
end

template "/etc/btsync/config.conf" do
  source "conf.json.erb"
  owner node["btsync"]["user"]
  group node["btsync"]["group"]
  mode "0400"
end

service "btsync" do
  supports [:restart, :reload, :status]
  action [:enable, :start]
end
