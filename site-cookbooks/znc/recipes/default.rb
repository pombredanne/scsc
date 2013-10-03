include_recipe "upgrades"

%w(socat znc znc-extra znc-python).each do |p|
  package p do
    action :upgrade
  end
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

directory "/var/lib/znc/configs" do
  action :create
  recursive true
  group "znc"
  owner "znc"
end

template "/var/lib/znc/configs/znc.conf" do
  source "znc.conf.erb"
  group "znc"
  owner "znc"
  mode "0750"
end

template "/etc/init/znc.conf" do
  source "znc.upstart.conf.erb"
  mode "0755"
end

template "/etc/init/socat-freenode.conf" do
  source "socat-freenode.conf.erb"
  mode "0755"
end

%w(znc socat-freenode).each do |srv|
  service srv do
    provider Chef::Provider::Service::Upstart
    supports [:restart, :reload, :status]
    action [:enable, :start]
  end
end
