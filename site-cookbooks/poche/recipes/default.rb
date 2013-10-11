include_recipe "php"
include_recipe "git"

git node["poche"]["root"] do
  repository "git://github.com/inthepoche/poche.git"
  reference "master"
  action :sync
end

bash "install poche" do
  cwd node["poche"]["root"]
  code <<-EOH
  chown www-data:data assets
  chown www-data:data cache
  composer install
  cp install/poche.sqlite /data/poche.sqlite
  cp inc/poche/config.inc.php.new inc/poche/config.inc.php
  EOH
  creates "/data/poche.sqlite"
end

poche_conf = ::File.join(node["poche"]["root"], "inc/poche/config.inc.php")

ruby_block "change poche db path" do
  block do
    f = Chef::Util::FileEdit.new(poche_conf)
    f.search_file_replace_line /define \('STORAGE_SQLITE.*/, "define ('STORAGE_SQLITE', '/data/poche.sqlite');"
    f.write_file
  end
  not_if { ::File.read(poche_conf).include? "/data/poche.sqlite" }
end
