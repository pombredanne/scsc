include_recipe "git"
include_recipe "znc::znc"

src_path = ::File.join Chef::Config[:file_cache_path], "znc-palaver"

git src_path do
  repository "git://github.com/Palaver/znc-palaver.git"
  reference "master"
  action :sync
end

bash "compile and install znc-palaver" do
  cwd src_path
  code <<-EOH
  make
  mv palaver.so /var/lib/znc/modules/palaver.so
  chown znc:znc /var/lib/znc/modules/palaver.so
  EOH
  creates "/var/lib/znc/modules/palaver.so"
end
