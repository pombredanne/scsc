include_recipe "build-essential"
include_recipe "git"

package "libtool"

src_path = ::File.join Chef::Config[:file_cache_path], "libsodium"

git src_path do
  repository "git://github.com/jedisct1/libsodium.git"
  reference "master"
  action :sync
end

bash "Compile and install libsodium" do
  cwd src_path
  code <<-EOH
  ./autogen.sh
  ./configure --libdir=/usr/local/lib
  make && make check && make install
  ldconfig
  EOH
  creates "/usr/local/lib/libsodium.so.4"
end
