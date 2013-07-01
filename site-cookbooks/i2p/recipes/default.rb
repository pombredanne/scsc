include_recipe "apt"

apt_repository "i2p" do
  uri "http://ppa.launchpad.net/i2p-maintainers/i2p/ubuntu"
  distribution node["lsb"]["codename"]
  components ["main"]
  keyserver "keyserver.ubuntu.com"
  key "EB2CC88B"
end

package "i2p"

execute "Reconfigure i2p" do
  command "dpkg-reconfigure -f noninteractive i2p"
end

service "i2p" do
  supports :status => true, :restart => true, :reload => true
  action [:enable, :start]
end
