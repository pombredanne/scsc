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
  chown www-data .
  composer install
  cp install/poche.sqlite db/poche.sqlite
  cp inc/poche/config.inc.php.new inc/poche/config.inc.php
  EOH
  creates ::File.join node["poche"]["root"], "db/poche.sqlite"
end
