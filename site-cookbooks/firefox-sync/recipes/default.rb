include_recipe "mercurial"
include_recipe "python"

%w(sqlite3 libssl-dev).each do |p|
  package p
end

src_path = "/opt/firefox-sync"

mercurial src_path do
  repository "https://hg.mozilla.org/services/server-full"
  reference "tip"
  action :sync
end

bash "Compile and install firefox-sync" do
  cwd src_path
  code "make build"
  creates ::File.join(src_path, "bin/paster")
end

user node["firefox-sync"]["user"] do
  shell "/bin/false"
  gid "data"
  system true
  action :create
end

template ::File.join(src_path, "etc/sync.conf") do
  source "sync.conf.erb"
  owner node["firefox-sync"]["user"]
  group node["firefox-sync"]["group"]
  mode "0644"
end
