include_recipe "apt"
include_recipe "folders"

apt_repository "transmissionbt" do
  uri "http://ppa.launchpad.net/transmissionbt/ppa/ubuntu"
  distribution node["lsb"]["codename"]
  components ["main"]
  keyserver "keyserver.ubuntu.com"
  key "365C5CA1"
end

package "transmission-daemon" do
  action :upgrade
end

group "data" do
  action :modify
  members "debian-transmission"
  append true
end

template "/etc/transmission-daemon/settings.json" do
  source "settings.json.erb"
  owner "debian-transmission"
  group "debian-transmission"
  mode "0700"
end

service "transmission-daemon" do
  supports [:restart, :reload, :status]
  action [:enable, :start]
end
