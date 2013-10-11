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
  cat inc/poche/config.inc.php.new | sed -e "s/'STORAGE_SQLITE', ROOT . '\/db\/poche.sqlite'/'STORAGE_SQLITE', '\/data\/poche.sqlite'/" > inc/poche/config.inc.php
  EOH
  creates "/data/poche.sqlite"
end
