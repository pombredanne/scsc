directory "/data" do
  owner "www-data"
  mode "0775"
  action :create
end

directory "/data/files" do
  owner "www-data"
  mode "0775"
  action :create
end
