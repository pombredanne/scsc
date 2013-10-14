default["znc"]["user"] = "znc"
default["znc"]["group"] = "znc"
default["znc"]["port"] = 6667
default["znc"]["irc2p-port"] = 6668
default["znc"]["freenode-address"] = '$(dig +short irc.tor.freenode.net cname | sed -E "s/([^\.]+\.[^\.]+)\./\1/")'
default["znc"]["socat-freenode-port"] = 6669
default["znc"]["onionnet-address"] = "ftwircdwyhghzw4i.onion"
default["znc"]["socat-onionnet-port"] = 6670
