include_recipe "apt"

apt_repository "tor" do
  uri "http://deb.torproject.org/torproject.org"
  distribution node["lsb"]["codename"]
  components ["main"]
  keyserver "keys.gnupg.net"
  key "886DDD89"
end

package "tor" do
  action :upgrade
end

service "tor" do
  supports [:restart, :reload, :status]
  action [:enable, :start]
end
