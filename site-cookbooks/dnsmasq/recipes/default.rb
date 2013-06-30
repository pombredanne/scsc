package "dnsmasq"

service "dnsmasq" do
  supports :restart => true
  action [:enable, :start]
end

template "/etc/dnsmasq.conf" do
  source "dnsmasq.conf.erb"
  owner "root"
  notifies :restart, "service[dnsmasq]"
end

dns_conf_path = "/etc/resolvconf/resolv.conf.d/head"
dns_line = "nameserver 127.0.0.1"

execute "Set up resolv to use dnsmasq" do
  command "echo '#{dns_line}' >> #{dns_conf_path}; resolvconf -u"
  not_if { ::File.read(dns_conf_path).include?(dns_line) }
end
