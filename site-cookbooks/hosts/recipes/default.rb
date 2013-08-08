include_recipe "apache2"
include_recipe "apache2::mod_proxy"
include_recipe "apache2::mod_proxy_http"
include_recipe "apache2::mod_dav_fs"
include_recipe "apache2::mod_wsgi"
include_recipe "i2p"
include_recipe "btsync"
include_recipe "firefox-sync"
include_recipe "folders"

group "data" do
  action :modify
  members "www-data"
  append true
end

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

web_app "weave-wsgi" do
  template "wsgi.conf.erb"
  server_name "weave.scsc"
  port 80
  document_root "/opt/firefox-sync"
  wsgi_script "sync.wsgi"
  process "sync"
  process_group "sync"
  process_user "sync"
  process_user_group "sync"
  processes 2
  threads 25
end
