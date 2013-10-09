include_recipe "znc"

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
  "tor-dns-proxy" => "/var/run/tor-dns-proxy.pid",
  "dnscrypt-proxy-primary" => "/var/run/dnscrypt-proxy-primary.pid",
  "dnscrypt-proxy-secondary" => "/var/run/dnscrypt-proxy-secondary.pid",
  "dnscrypt-proxy-opendns" => "/var/run/dnscrypt-proxy-opendns.pid",
  "socat-freenode" => "/var/run/socat-freenode.pid"
}

hosts = {}

ports = {
  "znc" => node["znc"]["port"],
  "i2p" => 7657,
  "dnsmasq" => 53,
  "dnscrypt-proxy-primary" => 2053,
  "dnscrypt-proxy-secondary" => 3053,
  "dnscrypt-proxy-opendns" => 4053,
  "privoxy" => node["privoxy"]["port"],
  "socat-freenode" => node["znc"]["socat-freenode-port"],
  "tor" => node["tor"]["socks-port"],
  "tor-dns-proxy" => node["tor"]["socks-resolver-port"]
}

types = {
  "dnsmasq" => "udp",
  "dnscrypt-proxy-primary" => "udp",
  "dnscrypt-proxy-secondary" => "udp",
  "dnscrypt-proxy-opendns" => "udp"
}

protos = {
  "dnsmasq" => "dns",
  "dnscrypt-proxy-primary" => "dns",
  "dnscrypt-proxy-secondary" => "dns",
  "dnscrypt-proxy-opendns" => "dns",
  "privoxy" => "default",
  "socat-freenode" => "default",
  "tor" => "default",
  "tor-dns-proxy" => "default"
}

%w(apache2
dnsmasq dnscrypt-proxy-primary dnscrypt-proxy-secondary dnscrypt-proxy-opendns
i2p tor tor-dns-proxy socat-freenode privoxy
znc).each do |rc|
  template "/etc/monit/conf.d/#{rc}" do
    source "process.erb"
    variables({
      :process  => rc,
      :pidfile  => pids[rc]   || "/var/run/#{rc}/#{rc}.pid",
      :start    => "/usr/sbin/service #{rc} start",
      :stop     => "/usr/sbin/service #{rc} stop",
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
