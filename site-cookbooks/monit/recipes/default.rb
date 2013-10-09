include_recipe "znc"

package "monit" do
  action :upgrade
end

template "/etc/monit/monitrc" do
  source "monitrc.erb"
  notifies :restart, "service[monit]"
end

pids = {
  "privoxy" => "/var/run/privoxy.pid",
  "tor-dns-proxy" => "/var/run/tor-dns-proxy.pid"
}

starts = {
  "tor-dns-proxy" => "/usr/sbin/service tor-dns-proxy start"
}

stops = {
  "tor-dns-proxy" => "/usr/sbin/service tor-dns-proxy stop"
}

ports = {
  "znc" => node["znc"]["port"],
  "i2p" => 7657,
  "dnsmasq" => 53,
  "privoxy" => node["privoxy"]["port"],
  "tor-dns-proxy" => node["tor"]["socks-resolver-port"]
}

types = {
  "dnsmasq" => "udp"
}

protocols = {
  "dnsmasq" => "dns",
  "tor-dns-proxy" => :noprotocol
}

%w(znc i2p dnsmasq privoxy tor-dns-proxy).each do |rc|
  template "/etc/monit/conf.d/#{rc}" do
    source "process.erb"
    variables({
      :process  => rc,
      :pidfile  => pids[rc] || "/var/run/#{rc}/#{rc}.pid",
      :start    => starts[rc] || "/etc/init.d/#{rc} start",
      :stop     => stops[rc] || "/etc/init.d/#{rc} stop",
      :port     => ports[rc],
      :type     => types[rc] || "tcp",
      :protocol => protocols[rc] || "http"
    })
    notifies :restart, "service[monit]"
  end
end

service "monit" do
  supports [:restart, :reload, :status]
  action [:enable, :start]
end
