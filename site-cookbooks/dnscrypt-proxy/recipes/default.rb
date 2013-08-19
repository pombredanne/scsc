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
  supports :manage_home => true
  shell "/bin/false"
  system true
  home "/home/#{node["dnscrypt-proxy"]["user"]}"
  action :create
end

%w(primary secondary).each do |rslv|
  template "/etc/init/dnscrypt-proxy-#{rslv}.conf" do
    source "dnscrypt-proxy.conf.erb"
    resolver rslv
    owner node["dnscrypt-proxy"]["user"]
    mode "0600"
    notifies :restart, "service[dnscrypt-proxy-#{rslv}]"
  end

  service "dnscrypt-proxy-#{rslv}" do
    provider Chef::Provider::Service::Upstart
    supports [:restart, :reload, :status]
    action [:enable, :start]
  end
end
