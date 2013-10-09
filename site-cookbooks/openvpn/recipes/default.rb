#
# Cookbook Name:: openvpn
# Recipe:: default
#
# 
# Copyright 2009, James Golick
#           2013, Greg V
#
# Distributable under the terms of the MIT license.

include_recipe "hostname"

%w(openvpn bridge-utils apparmor-utils secure-delete).each do |p|
  package p do
    action :upgrade
  end
end

service "openvpn" do
  supports :restart => true
  action :enable
end

execute "Add br interface" do
  line = "auto lo br0"
  command "echo '#{line}' >> /etc/network/interfaces && /etc/init.d/networking restart"
  not_if  "cat /etc/network/interfaces | grep -q '#{line}'"
end

directory "/etc/openvpn/easy-rsa" do
  action :create
  owner  "root"
  group  "sudo"
end

execute "copy easy-rsa files" do
  command "cp -R /usr/share/doc/openvpn/examples/easy-rsa/2.0/* /etc/openvpn/easy-rsa"
  not_if  "test -f /etc/openvpn/easy-rsa/openssl.cnf"
end

template "/etc/openvpn/easy-rsa/vars" do
  source "vars.erb"
  mode   0755
end

template "/etc/openvpn/easy-rsa/create-server-ca" do
  source "create-server-ca.erb"
  mode   0755
end

execute "setup server CA" do
  command "/etc/openvpn/easy-rsa/create-server-ca"
  creates "/etc/openvpn/server.crt"
end

template "/etc/openvpn/up.sh" do
  source "up.sh.erb"
  mode 0755
end

template "/etc/openvpn/down.sh" do
  source "down.sh.erb"
  mode 0755
end

execute "setup ip_forwarding" do
  command "echo 1 > /proc/sys/net/ipv4/ip_forward"
  not_if  "cat /proc/sys/net/ipv4/ip_forward | grep -q 1"
end

ruby_block "permanently setup ip_forwarding" do
  block do
    f = Chef::Util::FileEdit.new("/etc/sysctl.conf")
    f.search_file_replace_line /#net\.ipv4\.ip_forward=1/, "net.ipv4.ip_forward=1"
    f.write_file
  end
end

execute "setup iptables" do
  command "/sbin/iptables -t nat -A POSTROUTING -s 10.4.0.1/2 -o eth0 -j MASQUERADE"
end

template "/etc/openvpn/server.conf" do
  source "server.conf.erb"
  mode 0755
  notifies :restart, resources(:service => "openvpn")
end

template "/etc/openvpn/client.conf" do
  source "client.conf.erb"
end

template "/etc/openvpn/easy-rsa/make_client_package" do
  source "make_client_package.erb"
  mode 0755
end

template "/etc/apparmor.d/usr.sbin.openvpn" do
  source "apparmor.erb"
  owner "root"
  mode "0600"
end

bash "Enforce apparmor for openvpn" do
  code <<-EOH
  aa-enforce /usr/sbin/openvpn
  EOH
end

service "openvpn" do
  supports :restart => true
  action :start
end
