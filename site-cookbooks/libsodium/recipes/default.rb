include_recipe "build-essential"
include_recipe "git"

src_path = ::File.join Chef::Config[:file_cache_path], "libsodium"

git src_path do
  repository "git://github.com/jedisct1/libsodium.git"
  reference "master"
  action :sync
end

execute "Compile and install libsodium" do
  cwd src_path
  command "./autogen.sh; ./configure --libdir=/usr/local/lib; make; make check; make install; ldconfig"
  not_if { ::File.exists? "/usr/lib/libsodium.so.4" }
end
