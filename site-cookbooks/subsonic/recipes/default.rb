%w(unzip openjdk-7-jre-headless).each do |p|
  package p do
    action :upgrade
  end
end

jetty_path = "/opt/jetty-runner.jar"
subsonic_path = "/opt/subsonic.war"
subsonic_zip_path = ::File.join Chef::Config[:file_cache_path], "subsonic.zip"

remote_file jetty_path do
  source "http://repo1.maven.org/maven2/org/eclipse/jetty/jetty-runner/9.0.6.v20130930/jetty-runner-9.0.6.v20130930.jar"
  mode "0644"
  action :create_if_missing
end


remote_file subsonic_zip_path do
  source "http://downloads.sourceforge.net/project/subsonic/subsonic/4.8/subsonic-4.8-war.zip"
  mode "0644"
  action :create_if_missing
end

bash "unzip subsonic" do
  code "unzip #{subsonic_zip_path} -d /opt"
  creates subsonic_path
end

user node["subsonic"]["user"] do
  shell "/bin/false"
  gid node["subsonic"]["group"]
  system true
  action :create
end

template "/etc/init/subsonic.conf" do
  source "subsonic.upstart.conf.erb"
  variables(:jetty_path => jetty_path, :subsonic_path => subsonic_path)
  mode "0755"
end

service "subsonic" do
  provider Chef::Provider::Service::Upstart
  supports [:restart, :reload, :status]
  action [:enable, :start]
end
