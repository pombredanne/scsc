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
  cp install/poche.sqlite #{node["poche"]["db"]}
  chown www-data:data #{node["poche"]["db"]}
  cp inc/poche/config.inc.php.new inc/poche/config.inc.php
  rm -r install
  EOH
  creates node["poche"]["db"]
end

poche_conf = ::File.join(node["poche"]["root"], "inc/poche/config.inc.php")
poche_salt = node["poche"]["salt"]

ruby_block "change poche db path and salt" do
  block do
    if ::File.exists?(poche_salt)
      salt = ::File.read(poche_salt)
    else
      require 'securerandom'
      salt = SecureRandom.hex
      ::File.write(poche_salt, salt)
    end
    f = Chef::Util::FileEdit.new(poche_conf)
    f.search_file_replace_line /define \('SALT.*/, "define ('SALT', '#{salt}');"
    f.search_file_replace_line /define \('STORAGE_SQLITE.*/, "define ('STORAGE_SQLITE', '#{node["poche"]["db"]}');"
    f.write_file
  end
  not_if { ::File.read(poche_conf).include? node["poche"]["db"] }
end
