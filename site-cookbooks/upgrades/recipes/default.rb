package "unattended-upgrades" do
  action :upgrade
end

template "/etc/apt/apt.conf.d/10periodic" do
  source "periodic.erb"
  owner "root"
  mode "0600"
end