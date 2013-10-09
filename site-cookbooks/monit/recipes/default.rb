include_recipe "znc"
c
package "monit" do
  action :upgrade
end

template "/etc/monit/monitrc" do
  source "monitrc.erb"
  notifies :restart, "service[monit]"
end

pids = {
  "apache2" => "/var/run/apache2.pid",
  "privoxy" => "/var/run/privoxy.pid",
  "tor-dns-proxy" => "/var/run/tor-dns-proxy.pid"
}

starts = {
  "tor-dns-proxy" => "/usr/sbin/service tor-dns-proxy start"
}

stops = {
  "tor-dns-proxy" => "/usr/sbin/service tor-dns-proxy stop"
}

hosts = {
  "apache2" => "apache2status.scsc"
}

ports = {
  "znc" => node["znc"]["port"],
  "i2p" => 7657,
  "dnsmasq" => 53,
  "privoxy" => node["privoxy"]["port"],
  "tor" => node["tor"]["socks-port"],
  "tor-dns-proxy" => node["tor"]["socks-resolver-port"]
}

types = {
  "dnsmasq" => "udp"
}

protos = {
  "apache2" => "apache-status",
  "dnsmasq" => "dns",
  "privoxy" => "default",
  "tor" => "default",
  "tor-dns-proxy" => "default"
}

%w(apache2 znc i2p dnsmasq privoxy tor tor-dns-proxy).each do |rc|
  template "/etc/monit/conf.d/#{rc}" do
    source "process.erb"
    variables({
      :process  => rc,
      :pidfile  => pids[rc]   || "/var/run/#{rc}/#{rc}.pid",
      :start    => starts[rc] || "/etc/init.d/#{rc} start",
      :stop     => stops[rc]  || "/etc/init.d/#{rc} stop",
      :host     => hosts[rc]  || "localhost",
      :port     => ports[rc]  || 80,
      :type     => types[rc]  || "tcp",
      :protocol => protos[rc] || "http"
    })
    notifies :restart, "service[monit]"
  end
end

service "monit" do
  supports [:restart, :reload, :status]
  action [:enable, :start]
end
