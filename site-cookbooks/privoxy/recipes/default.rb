package "privoxy"

service "privoxy" do
  supports :restart => true
  action [:enable, :start]
end

template "/etc/privoxy/config" do
  source "config.erb"
  owner "root"
  notifies :restart, "service[privoxy]"
end
