%w(php5 php5-curl php5-tidy php5-sqlite).each do |p|
  package p do
    action :upgrade
  end
end

bash "install composer" do
  cwd Chef::Config[:file_cache_path]
  code <<-EOH
  curl -sS https://getcomposer.org/installer | php
  mv composer.phar /usr/local/bin/composer
  EOH
  creates "/usr/local/bin/composer"
end
