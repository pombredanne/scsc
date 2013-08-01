package "tor"

service "tor" do
  supports [:restart, :reload, :status]
  action [:enable, :start]
end
