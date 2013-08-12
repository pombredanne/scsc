group "data" do
  action :create
end

directory "/data" do
  group "data"
  mode "0770"
  action :create
end

directory "/data/files" do
  group "data"
  mode "0770"
  action :create
end

# Users are added to the data group in other cookbooks

directory "/opt/scsc-plugins" do
  action :create
end
