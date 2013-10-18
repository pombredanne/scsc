# scsc – Secure Cloud Script Collection

SCSC is a set of Chef cookbooks that you can use to set up a personal cloud server (VPS) to provide services like file synchronization and tunnel your Internet access, powered by [OpenVPN][openvpn] with the most secure settings.

The services available on the server itself are:

- file storage, sync and access via [BitTorrent Sync][btsync] and WebDAV *instead of Dropbox*
- [Transmission][transmission] BitTorrent client
- browser sync via [Firefox Sync Server][weave] *instead of the public server*
- [ZNC][znc] IRC bouncer *instead of IRCCloud*
- [Coldsweat][coldsweat] Fever API-compatible RSS/Atom feed reader *instead of Feedly*
- [Poche][poche] read it later app *instead of Instapaper*

The server also tunnels your Internet traffic, improving security and providing access to more networks:

- as with any VPN tunnel, you're protected from your ISP (or a public Wi-Fi network you're using)
- DNS queries are resolved from [CloudNS][cloudns] (which resolves [.bit][dotbit] domains, performs DNSSEC validation and doesn't do any weird things) and [OpenNIC][opennic] using [DNSCrypt][dnscrypt]
- [tcpcrypt][tcpcrypt] is used
- the [I2P][i2p] network is available
- [Tor][tor] hidden services are available (**if you want to use Tor for anonymity though, use it on your local machine!**)
- [Privoxy][privoxy] blocks trackers and ads

## Setup

### Requirements

*Use [passphrases][passphrases], not passwords.
There's the [correcthorsebatterystaple.net][chbs] generator, but if you don't trust computers, check out [Diceware Passphrase][diceware].*

1. Establish a place where you can securely store cryptographic keys.  
   A [TrueCrypt][truecrypt]-powered [Hidden volume][truecrypt-hidden] on a small partition of a USB drive is a good solution.  
   [gfk][gfk] sounds interesting too.  
   **Warning**: Make sure you don't lose these keys.
2. Sign up for a trustworthy cloud server hosting provider in a country that has a good privacy record.
   That is, [GreenQloud][greenqloud] :-)
   Or [a provider that accepts bitcoin][btcvps].
3. cd to your key storage, generate a keypair for SSH (`ssh-keygen -t rsa -f id_rsa_scsc -b 4096`) with a passphrase.
4. Send the public key to the hosting provider.  
   For GreenQloud: install [euca2ools][euca2ools], sign in to my.greenqloud.com, User → API Access → Credentials → Download .zip, then something like this:
        
        mv ~/Downloads/gq_credentials* .
        unzip gq_credentials*
        source gq_credentials/rc
        /usr/local/bin/euca-import-keypair -f id_rsa_scsc.pub scsc
        
5. Copy the private key to your hard drive for now (because SSH can't use keys from the FAT file system): `cp id_rsa_scsc ~/.ssh/`

*It's also a good idea to set up full disk encryption on your devices.*

### Server setup

1. Create a security group, name it `scsc`, open up SSH (tcp port 22) and OpenVPN (udp port 1194). Also tcp ports 9001 and 9030 if you want to help the Tor network.
2. Create an instance with **Ubuntu Server 12.04 LTS**, the security group `scsc` and keypair `scsc`.
3. Add the instance to your `~/.ssh/config` like this (don't forget to change the hostname):
        
        Host scsc
          Hostname i-12-34-56-78.compute.is-1.greenqloud.com
          User ubuntu
          IdentityFile "~/.ssh/id_rsa_scsc"
        
4. `ssh scsc`, check the fingerprint, say yes.
5. Run the following commands on the server (again, don't forget to change the hostname):
        
        echo "i-12-34-56-78.compute.is-1.greenqloud.com" > /home/ubuntu/hostname
        curl -L https://raw.github.com/myfreeweb/scsc/master/install.sh | sudo bash
   
That's the installation process.
Some things are compiled from source, so it's not lightning fast.
You can start installing VPN client apps while it's running.

### VPN client setup

1. Install OpenVPN clients.  
   OS X: [Tunnelblick][tblk]  
   Mobile: OpenVPN Connect ([iOS][openvpn-ios], [Android][openvpn-android])
2. Do the following on the local machine (in the key storage directory) to get the key:
        
        ssh scsc sudo /etc/openvpn/easy-rsa/make_client_package client
        scp scsc:/home/ubuntu/client.tar.gz ./
        ssh scsc srm /home/ubuntu/client.tar.gz
        tar xvf client.tar.gz
        
3. You have the OpenVPN configuration files and keys in the `client` directory!

If you have an Android device with a hardware-backed keystore, make and import a PKCS#12 file as described in the in-app help for OpenVPN Connect.

### Two-factor SSH authentication

You can set up any TOTP (Time-based One Time Password) app ([Authy][authy] is great) to use with SSH.
Run `sudo scsc-ssh-totp init` on the server and follow the instructions.

If your code was rejected when logging in, try it after it expires.

### Browser setup

1. Use `privoxy.scsc:8118` as the HTTP proxy in your browser to access .i2p and .onion sites.
   Ignore the proxy for .scsc and .dev (.scsc resolves to the VPS, .dev to localhost).
   ![Firefox proxy settings screenshot](https://files.app.net/7cgckJ3L)

### Finishing

When everything works, securely delete the copy of the SSH key from your hard drive (`srm ~/.ssh/id_rsa_scsc` or `rm -P ~/.ssh/id_rsa_scsc`) and close port 22 (SSH) on your hosting provider's firewall (security group).

### Upgrading

To upgrade, copy the SSH key again, reopen port 22, connect to the server via SSH and run `sudo scsc-update`.

## Usage

All web services are using a self-signed SSL certificate.  
You have to confirm the security exception in your browser.

### BitTorrent Sync and WebDAV

BitTorrent Sync is available at [btsync.scsc](https://btsync.scsc).
Use the folder /data/files for syncing.
This is the folder that's available through WebDAV at [dav.scsc](https://dav.scsc).

### Firefox Sync

Firefox Sync (Mozilla Weave) is available at weave.scsc.  
[iCab Mobile][icab] on iOS supports Firefox Sync.
iCab asks for a Sync-Key - that's actually the Recovery Key.

### Tor

The [Tor][tor] SOCKS proxy is available at port 9050 (use any .scsc hostname, eg. tor.scsc.)
DNS resolver at 9053, control at 9051 with password `c0ntr0l` (which doesn't really matter because only you have access to this port through OpenVPN.)  
But **you should use Tor Browser Bundle (or better, Tails) on your own local machine when you want serious anonymity**.
And [read the warnings][tor-warnings].

If you want to help the Tor network by running a relay (not an exit node! you should not run an exit node on your scsc server), open tcp ports 9001 and 9030 on the firewall (security group.) 

### I2P

The [I2P router][i2p] console is available at [i2p.scsc](https://i2p.scsc).  
You need to use the HTTP proxy (see Browser setup above) to access I2P and Tor hidden services.

### ZNC (the IRC bouncer)

[ZNC][znc] 1.0 is running at port 6667, webadmin at [znc.scsc](https://znc.scsc).  
The default username and password are `admin` and `password`.

There are some networks preconfigured:

1. `freenode` is [freenode][freenode] over [SSL and Tor (with SASL auth)][freenode-tor].
   Connect to `znc.scsc:6667` with password `admin/freenode:password`, send `/msg *sasl set freenodeUsername freenodePassword`  
2. `irc2p` is [the I2P IRC network][irc2p].
3. `onionnet` is [the Tor-powered OnionNet][onionnet]

### Coldsweat (RSS/Atom feed reader)

[Coldsweat][coldsweat] is running at [coldsweat.scsc](https://coldsweat.scsc).  
Default username and password are both `coldsweat`.

### Poche (read it later)

[Poche][poche] is running at [poche.scsc](https://poche.scsc).

### Transmission

The [Transmission][transmission] web and remote interface is available at [transmission.scsc](https://transmission.scsc), without authentication.

## TODO

- tarsnap backup and restore
- bitcoind + coinpunk
- bitmessage + bmwrapper
- mail server
- xmpp server
- owncloud or something simpler for carddav & caldav


[openvpn]: http://openvpn.net/index.php/open-source.html
[btsync]: http://labs.bittorrent.com/experiments/sync.html
[transmission]: http://transmissionbt.com/
[weave]: http://docs.services.mozilla.com/howtos/run-sync.html
[znc]: http://wiki.znc.in/ZNC
[coldsweat]: https://github.com/passiomatic/coldsweat
[poche]: http://www.inthepoche.com/
[cloudns]: https://cloudns.com.au/
[dotbit]: http://dot-bit.org/Main_Page
[opennic]: http://www.opennicproject.org/
[dnscrypt]: http://dnscrypt.org/
[tcpcrypt]: http://tcpcrypt.org/
[i2p]: http://www.i2p2.de/
[tor]: https://www.torproject.org/
[privoxy]: http://www.privoxy.org/
[passphrases]: http://xkcd.com/936/
[chbs]: http://correcthorsebatterystaple.net/
[diceware]: http://world.std.com/~reinhold/diceware.html
[truecrypt]: http://www.truecrypt.org
[truecrypt-hidden]: http://www.truecrypt.org/hiddenvolume
[gfk]: http://gfk.eatabrick.org/
[greenqloud]: http://greenqloud.com
[btcvps]: https://en.bitcoin.it/wiki/Virtual_private_server
[euca2ools]: https://github.com/eucalyptus/euca2ools
[tblk]: http://code.google.com/p/tunnelblick/wiki/DownloadsEntry?tm=2
[openvpn-ios]: https://itunes.apple.com/us/app/openvpn-connect/id590379981?mt=8
[openvpn-android]: https://play.google.com/store/apps/details?id=net.openvpn.openvpn)
[authy]: https://www.authy.com/thefuture
[icab]: http://www.icab-mobile.de/
[tor-warnings]: https://www.torproject.org/download/download-easy.html.en#warning
[freenode]: http://freenode.net
[freenode-tor]: http://freenode.net/irc_servers.shtml#tor
[irc2p]: http://killyourtv.i2p.us/i2p/ircservers/irc2p/
[onionnet]: http://pastebin.com/9aTv2thj
