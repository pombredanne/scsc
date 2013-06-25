include_recipe "apt"

apt_repository "btsync" do
  uri "http://ppa.launchpad.net/tuxpoldo/btsync/ubuntu"
  distribution node["lsb"]["codename"]
  components ["main"]
  keyserver "keyserver.ubuntu.com"
  key "D294A752"
end

package "btsync"

service "btsync" do
  supports :status => true, :restart => true, :reload => true
  action [:enable, :start]
end
