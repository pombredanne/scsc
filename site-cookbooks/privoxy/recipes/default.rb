package "privoxy"

service "privoxy" do
  supports [:restart, :reload, :status]
  action [:enable, :start]
end

template "/etc/privoxy/config" do
  source "config.erb"
  owner "privoxy"
  group "privoxy"
  mode "0600"
  notifies :restart, "service[privoxy]"
end
