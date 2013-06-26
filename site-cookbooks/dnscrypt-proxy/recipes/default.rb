include_recipe "build-essential"
include_recipe "git"
include_recipe "libsodium"

package "libtool"

src_path = ::File.join Chef::Config[:file_cache_path], "dnscrypt-proxy"
dns_conf_path = "/etc/resolvconf/resolv.conf.d/head"
dns_line = "nameserver 127.0.0.1"

git src_path do
  repository "git://github.com/jedisct1/dnscrypt-proxy.git"
  reference "master"
  action :sync
end

bash "Compile and install dnscrypt-proxy" do
  cwd src_path
  code <<-EOH
  ./autogen.sh
  ./configure
  make && make install
  EOH
  creates "/usr/local/sbin/dnscrypt-proxy"
end

cookbook_file "/etc/init/dnscrypt-proxy.conf"

service "dnscrypt-proxy" do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :reload => true
  action [:enable, :start]
end

execute "Set up resolv to use dnscrypt-proxy" do
  command "echo '#{dns_line}' >> #{dns_conf_path}; resolvconf -u"
  not_if { ::File.read(dns_conf_path).include?(dns_line) }
end
