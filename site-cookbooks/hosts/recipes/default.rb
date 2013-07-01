include_recipe "apache2"
include_recipe "apache2::mod_proxy"
include_recipe "apache2::mod_proxy_http"
include_recipe "apache2::mod_dav_fs"

web_app "dav" do
  template "dav.conf.erb"
  server_name "dav.scsc"
  port 80
  document_root "/data/files"
end

web_app "i2p-proxy" do
  template "proxy.conf.erb"
  server_name "i2p.scsc"
  port 80
  dest "http://localhost:7657/"
end

web_app "btsync-proxy" do
  template "proxy.conf.erb"
  server_name "btsync.scsc"
  port 80
  dest "http://localhost:8888/"
end
