include_recipe "git"
include_recipe "znc::znc"

src_path = ::File.join Chef::Config[:file_cache_path], "znc-push"

git src_path do
  repository "git://github.com/jreese/znc-push.git"
  reference "master"
  action :sync
end

bash "compile and install znc-push" do
  cwd src_path
  code <<-EOH
  make
  mv push.so /var/lib/znc/modules/push.so
  chown znc:znc /var/lib/znc/modules/push.so
  EOH
  creates "/var/lib/znc/modules/push.so"
end
