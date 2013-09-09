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

service "i2p" do
  supports :restart => true
  action [:enable, :start]
end

group "data" do
  action :modify
  members "i2psvc"
  append true
end
