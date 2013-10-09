package "monit" do
  action :upgrade
end

template "/etc/monit/monitrc" do
  source "monitrc.erb"
end

%w(znc).each do |rc|
  template "/etc/monit/conf.d/#{rc}" do
    source "#{rc}.erb"
  end
end

service "monit" do
  supports [:restart, :reload, :status]
  action [:enable, :start]
end
