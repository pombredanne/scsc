include_recipe "build-essential"
include_recipe "git"
include_recipe "libsodium"

package "libtool"

src_path = ::File.join Chef::Config[:file_cache_path], "dnscrypt-proxy"

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

user node["dnscrypt-proxy"]["user"] do
  shell "/bin/false"
  system true
  action :create
end

template "/etc/init/dnscrypt-proxy.conf" do
  source "dnscrypt-proxy.conf.erb"
  owner node["dnscrypt-proxy"]["user"]
  mode "0600"
  notifies :restart, "service[dnscrypt-proxy]"
end

service "dnscrypt-proxy" do
  provider Chef::Provider::Service::Upstart
  supports [:restart, :reload, :status]
  action [:enable, :start]
end
