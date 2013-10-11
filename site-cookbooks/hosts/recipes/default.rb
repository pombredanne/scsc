include_recipe "apache2"
include_recipe "apache2::mod_proxy"
include_recipe "apache2::mod_proxy_http"
include_recipe "apache2::mod_dav_fs"
include_recipe "apache2::mod_wsgi"
include_recipe "apache2::mod_php5"
include_recipe "monit"
include_recipe "i2p"
include_recipe "btsync"
include_recipe "firefox-sync"
include_recipe "coldsweat"
include_recipe "folders"

bash "install composer" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
  curl -sS https://getcomposer.org/installer | php
  mv composer.phar /usr/local/bin/composer
  EOH
  creates "/usr/local/bin/composer"
end

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

web_app "monit-proxy" do
  template "proxy.conf.erb"
  server_name "monit.scsc"
  port 80
  dest "http://localhost:#{@node["monit"]["httpd-port"]}/"
end

web_app "znc-proxy" do
  template "proxy.conf.erb"
  server_name "znc.scsc"
  port 80
  dest "http://localhost:#{@node["znc"]["port"]}/"
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
  dest "http://localhost:#{@node["btsync"]["webui-port"]}/"
end

web_app "transmission-proxy" do
  template "proxy.conf.erb"
  server_name "transmission.scsc"
  port 80
  dest "http://localhost:#{@node["transmission"]["rpc-port"]}/"
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
  process_user_group "data"
  processes 2
  threads 20
end

web_app "coldsweat-wsgi" do
  template "wsgi.conf.erb"
  server_name "coldsweat.scsc"
  port 80
  document_root "/opt/coldsweat"
  wsgi_script "coldsweat.wsgi"
  process "coldsweat"
  process_group "coldsweat"
  process_user "coldsweat"
  process_user_group "data"
  processes 2
  threads 20
end
