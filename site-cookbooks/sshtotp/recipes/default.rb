include_recipe "python"

%w(libssl-dev).each do |p|
  package p
end

python_pip "pyotp"

script = "/usr/bin/scsc-ssh-totp"
sshd_conf = "/etc/ssh/sshd_config"

cookbook_file script do
  mode 0755
  owner "root"
end

ruby_block "add scsc-ssh-totp to sshd_config" do
  block do
    f = Chef::Util::FileEdit.new(sshd_conf)
    f.search_file_replace_line /^AcceptEnv LANG LC_*$/, "AcceptEnv TOTP_CODE LANG LC_*\nForceCommand #{script} ssh-verify"
    f.write_file
  end
  not_if { ::File.read(sshd_conf).include? "ForceCommand" }
end


service "ssh" do
  supports :restart => true
  action :restart
end
