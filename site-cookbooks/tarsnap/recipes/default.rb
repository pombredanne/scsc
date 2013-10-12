include_recipe "build-essential"
include_recipe "python"
include_recipe "folders"

src_name = "tarsnap-autoconf-1.0.35"
tarball_name = "#{src_name}.tgz"
src_path = ::File.join Chef::Config[:file_cache_path], src_name
tarball_path = ::File.join Chef::Config[:file_cache_path], tarball_name

%w{libssl-dev zlib1g-dev e2fslibs-dev}.each do |p|
  package p
end

remote_file tarball_path do
  source "https://www.tarsnap.com/download/#{tarball_name}"
  mode "0644"
  action :create_if_missing
end

execute "Extract tarsnap" do
  cwd Chef::Config[:file_cache_path]
  command "tar zxvf #{tarball_name}"
  creates src_path
end

bash "Compile and install tarsnap" do
  cwd src_path
  code <<-EOH
  ./configure
  make all install clean
  EOH
  creates "/usr/local/bin/tarsnap"
end

directory node["tarsnap"]["cachedir"] do
  action :create
end

template node["tarsnap"]["tarsnap-config"] do
  source "tarsnap.conf.erb"
end

python_pip "tarsnapper"

template node["tarsnap"]["tarsnapper-config"] do
  source "tarsnapper.yml.erb"
end

cron "tarsnapper" do
  minute "0"
  hour "*/6"
  day "*"
  month "*"
  user "root"
  command "/usr/local/bin/tarsnapper -c #{node["tarsnap"]["tarsnapper-config"]} make"
  action :create
end
