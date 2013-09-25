include_recipe "apt"

apt_repository "tor" do
  uri "http://deb.torproject.org/torproject.org"
  distribution node["lsb"]["codename"]
  components ["main"]
  keyserver "keys.gnupg.net"
  key "886DDD89"
end

%w(tor tor-arm).each do |p|
  package p do
    action :upgrade
  end
end

template "/etc/tor/torrc" do
  source "torrc.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, "service[tor]"
end

service "tor" do
  supports [:restart, :reload, :status]
  action [:enable, :start]
end
