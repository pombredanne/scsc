package "unattended-upgrades" do
  action :upgrade
end

template "/etc/apt/apt.conf.d/10periodic" do
  source "periodic.erb"
  owner "root"
  mode "0600"
end

template "/etc/apt/preferences" do
  source "preferences.erb"
  owner "root"
  mode "0600"
end

ruby_block "Enable backports" do
  block do
    sources = Chef::Util::FileEdit.new "/etc/apt/sources.list"
    sources.search_file_replace /# deb ([^ ]+) ([^-]+)-backports main restricted universe multiverse/,
      "deb \\1 \\2-backports main restricted universe multiverse"
    sources.write_file
  end
end

execute "Do update" do
  command "apt-get update"
end
