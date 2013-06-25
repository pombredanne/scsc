include_recipe "build-essential"
include_recipe "git"

%w{iptables libcap-dev libssl-dev libnfnetlink-dev libnetfilter-queue-dev}.each do |p|
  package p
end

src_path = "/opt/tcpcrypt"
src_code_path = ::File.join src_path, "user"

execute "Compile tcpcrypt" do
  cwd src_code_path
  command "./configure; make"
  action :nothing
  not_if { ::File.exists? ::File.join(src_code_path, "src/tcpcryptd") }
end

git src_path do
  repository "git://github.com/sorbo/tcpcrypt.git"
  reference "master"
  action :sync
  notifies :run, resources(:execute => "Compile tcpcrypt"), :immediately
end

cookbook_file "/etc/init/tcpcrypt.conf"

service "tcpcrypt" do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :reload => true
  action [:enable, :start]
end
