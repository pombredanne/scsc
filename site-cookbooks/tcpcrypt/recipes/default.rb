include_recipe "build-essential"
include_recipe "git"

%w{iptables libcap-dev libssl-dev libnfnetlink-dev libnetfilter-queue-dev}.each do |p|
  package p
end

src_path = "/opt/tcpcrypt"
src_code_path = ::File.join src_path, "user"

git src_path do
  repository "git://github.com/sorbo/tcpcrypt.git"
  reference "master"
  action :sync
end

execute "Compile tcpcrypt" do
  cwd src_code_path
  command "./configure; make"
  not_if { ::File.exists? ::File.join(src_code_path, "src/tcpcryptd") }
end

cookbook_file "/etc/init/tcpcrypt.conf" do
  mode "0600"
end

service "tcpcrypt" do
  provider Chef::Provider::Service::Upstart
  supports [:restart, :reload, :status]
  action [:enable, :start]
end
