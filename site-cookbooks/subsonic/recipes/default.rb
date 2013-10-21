%w(unzip lame openjdk-7-jdk).each do |p|
  package p do
    action :upgrade
  end
end

runner_path = "/opt/webapp-runner.jar"
subsonic_path = "/opt/subsonic.war"
subsonic_zip_path = ::File.join Chef::Config[:file_cache_path], "subsonic.zip"

remote_file runner_path do
  source "http://jsimone.github.io/webapp-runner/repository/com/github/jsimone/webapp-runner/0.0.7/webapp-runner-0.0.7.jar"
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
  supports :manage_home => true
  shell "/bin/false"
  gid node["subsonic"]["group"]
  home node["subsonic"]["home"]
  system true
  action :create
end

template "/etc/init/subsonic.conf" do
  source "subsonic.upstart.conf.erb"
  variables(:runner_path => runner_path, :subsonic_path => subsonic_path)
  mode "0755"
end

service "subsonic" do
  provider Chef::Provider::Service::Upstart
  supports [:restart, :reload, :status]
  action [:enable, :start]
end
