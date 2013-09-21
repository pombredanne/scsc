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
    open sshd_conf, "a" do |f|
      f.puts "ForceCommand #{script} ssh-verify"
    end
  end
  not_if { ::File.read(sshd_conf).include? "ForceCommand" }
end
