include_recipe "apt"

apt_repository "i2p" do
  uri "http://ppa.launchpad.net/i2p-maintainers/i2p/ubuntu"
  distribution node["lsb"]["codename"]
  components ["main"]
  keyserver "keyserver.ubuntu.com"
  key "EB2CC88B"
end

execute "Preconfigure i2p" do
  command "echo i2p i2p/daemon boolean true | debconf-set-selections"
end

package "i2p" do
  action :upgrade
end

group "data" do
  action :modify
  members "i2psvc"
  append true
end

template "/var/lib/i2p/i2p-config/addressbook/subscriptions.txt" do
  source "subscriptions.txt.erb"
  owner "i2psvc"
  group "i2psvc"
  mode "0600"
end

service "i2p" do
  supports :restart => true
  action [:enable, :start]
end
