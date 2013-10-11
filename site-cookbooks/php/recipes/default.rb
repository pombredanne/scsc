package "php5" do
  action :upgrade
end

bash "install composer" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
  curl -sS https://getcomposer.org/installer | php
  mv composer.phar /usr/local/bin/composer
  EOH
  creates "/usr/local/bin/composer"
end
