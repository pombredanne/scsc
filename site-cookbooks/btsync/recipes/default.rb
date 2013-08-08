include_recipe "apt"
include_recipe "folders"

apt_repository "btsync" do
  uri "http://ppa.launchpad.net/tuxpoldo/btsync/ubuntu"
  distribution node["lsb"]["codename"]
  components ["main"]
  keyserver "keyserver.ubuntu.com"
  key "D294A752"
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

template "/etc/default/btsync" do
  source "default.erb"
  owner "root"
  group "root"
  mode "0640"
end

service "btsync" do
  supports [:restart, :reload, :status]
  action [:enable, :start]
end
