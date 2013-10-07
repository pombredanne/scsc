include_recipe "git"
include_recipe "python"

user node["coldsweat"]["user"] do
  shell "/bin/false"
  gid node["coldsweat"]["group"]
  system true
  action :create
end

src_path = "/opt/coldsweat"

git src_path do
  repository "git://github.com/passiomatic/coldsweat.git"
  reference "master"
  action :sync
end

bash "Change owner of coldsweat repo" do
  code <<-EOH
  chown coldsweat:data /opt/coldsweat
  EOH
end

python_virtualenv ::File.join(src_path, "venv") do
  owner node["coldsweat"]["user"]
  group node["coldsweat"]["group"]
  action :create
end

template ::File.join(src_path, "etc/config") do
  source "config.erb"
  owner node["coldsweat"]["user"]
  group node["coldsweat"]["group"]
  mode "0644"
end

template ::File.join(src_path, "coldsweat.wsgi") do
  source "coldsweat.wsgi.erb"
  owner node["coldsweat"]["user"]
  group node["coldsweat"]["group"]
  mode "0644"
end

bash "Install deps and create user for coldsweat" do
  cwd src_path
  code <<-EOH
  source venv/bin/activate
  pip install -r requirements.txt
  python -c 'from coldsweat.models import *; setup(); User.create(username="reader", password="p@ssw0rd", api_key=User.make_api_key("reader", "p@ssw0rd"))'
  deactivate
  EOH
  creates "/data/coldsweat.db"
end

cron "refresh_coldsweat" do
  minute "30"
  hour "*"
  day "*"
  month "*"
  user node["coldsweat"]["user"]
  command <<-EOH
  source venv/bin/activate
  python sweat.py refresh
  deactivate
  EOH
  action :create
end
