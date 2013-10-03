include_recipe "build-essential"

%w(socat libssl-dev openssl swig automake libtool libsasl2-dev checkinstall g++ pkg-config python3-dev).each do |p|
  package p do
    action :upgrade
  end
end

src_name = "znc-1.0"
tarball_name = "#{src_name}.tar.gz"
src_path = ::File.join Chef::Config[:file_cache_path], src_name
tarball_path = ::File.join Chef::Config[:file_cache_path], tarball_name

remote_file tarball_path do
  source "http://znc.in/releases/#{tarball_name}"
  mode "0644"
  action :create_if_missing
end

execute "Extract znc" do
  cwd Chef::Config[:file_cache_path]
  command "tar zxvf #{tarball_name}"
  creates src_path
end

bash "Compile and install znc" do
  cwd src_path
  code <<-EOH
  ./configure --enable-python
  make install
  EOH
  creates "/usr/local/bin/znc"
end

group node["znc"]["group"] do
  action :create
end

user node["znc"]["user"] do
  supports :manage_home => true
  gid node["znc"]["group"]
  shell "/bin/false"
  system true
  home "/var/lib/znc"
  action :create
end

template "/etc/init.d/znc" do
  source "init.erb"
  mode "0755"
end

template "/etc/init/socat-freenode.conf" do
  source "socat-freenode.conf.erb"
  mode "0755"
end

service "znc" do
  supports [:restart, :reload, :status]
  action [:enable, :start]
end

service "socat-freenode" do
  provider Chef::Provider::Service::Upstart
  supports [:restart, :reload, :status]
  action [:enable, :start]
end
