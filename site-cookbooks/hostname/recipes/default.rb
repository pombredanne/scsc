hostfile = "/home/ubuntu/hostname"
raise "Please specify the hostname in #{hostfile} and run again." unless File.exists? hostfile
hostname = File.read(hostfile).strip

file "/etc/hostname" do
  content "#{hostname}\n"
end

service "hostname" do
  action :restart
end

file "/etc/hosts" do
  content "127.0.0.1 localhost #{hostname}\n"
end
