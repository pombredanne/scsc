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
