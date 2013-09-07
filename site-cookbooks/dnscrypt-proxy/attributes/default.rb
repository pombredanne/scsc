default["dnscrypt-proxy"]["user"] = "dnscrypt-proxy"

default["dnscrypt-proxy"]["primary"] = {
  "local-address"    => "127.0.0.1:2053",
  "provider-key"     => "1971:7C1A:C550:6C09:F09B:ACB1:1AF7:C349:6425:2676:247F:B738:1C5A:243A:C1CC:89F4",
  "provider-address" => "2.dnscrypt-cert.cloudns.com.au",
  "resolver-address" => "113.20.6.2",
  "resolver-port"    => "443"
}

default["dnscrypt-proxy"]["secondary"] = {
  "local-address"    => "127.0.0.1:3053",
  "provider-key"     => "67A4:323E:581F:79B9:BC54:825F:54FE:1025:8B4F:37EB:0D07:0BCE:4010:6195:D94F:E330",
  "provider-address" => "2.dnscrypt-cert-2.cloudns.com.au",
  "resolver-address" => "113.20.8.17",
  "resolver-port"    => "443"
}

default["dnscrypt-proxy"]["opennic"] = {
  "local-address"    => "127.0.0.1:4053",
  "provider-key"     => "8768:C3DB:F70A:FBC6:3B64:8630:8167:2FD4:EE6F:E175:ECFD:46C9:22FC:7674:A1AC:2E2A",
  "provider-address" => "2.dnscrypt-cert.ns2.jp.dns.opennic.glue",
  "resolver-address" => "106.186.17.181",
  "resolver-port"    => "2053"
}

default["dnscrypt-proxy"]["ports"] = %w(primary secondary opennic).map { |r|
  default["dnscrypt-proxy"][r]["resolver-port"]
}.uniq
