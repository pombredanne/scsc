# scsc – Secure Cloud Script Collection

SCSC is a set of Chef cookbooks that you can use to set up a personal cloud server (VPS) to provide services like file synchronization and tunnel your Internet access, powered by [OpenVPN](http://openvpn.net/index.php/open-source.html) with the most secure settings.

The services available on the server itself are:

- file storage, sync and access via [BitTorrent Sync](http://labs.bittorrent.com/experiments/sync.html) and WebDAV
- [Transmission](http://transmissionbt.com/) BitTorrent client
- browser sync via [Firefox Sync Server](http://docs.services.mozilla.com/howtos/run-sync.html)

The server also tunnels your Internet traffic, improving security and providing access to more networks:

- as with any VPN tunnel, you're protected from your ISP (or a public Wi-Fi network you're using)
- DNS queries are resolved from [CloudNS](https://cloudns.com.au/) (which resolves [.bit](http://dot-bit.org/Main_Page) domains, performs DNSSEC validation and doesn't do any weird things) and [OpenNIC](http://www.opennicproject.org/) using [DNSCrypt](http://dnscrypt.org/)
- [tcpcrypt](http://tcpcrypt.org/) is used
- the [I2P](http://www.i2p2.de/) network is available
- [Tor](https://www.torproject.org/) hidden services are available (**if you want to use Tor for anonymity though, use it on your local machine!**)
- [Privoxy](http://www.privoxy.org/) blocks trackers and ads

## Setup

### Requirements

*Use [passphrases](http://xkcd.com/936/), not passwords.
There's the [correcthorsebatterystaple.net](http://correcthorsebatterystaple.net/) generator, but if you don't trust computers, check out [Diceware Passphrase](http://world.std.com/~reinhold/diceware.html).*

1. Establish a place where you can securely store cryptographic keys.  
   A [TrueCrypt](http://www.truecrypt.org)-powered [Hidden volume](http://www.truecrypt.org/hiddenvolume) on a small partition of a USB drive or SD card is strongly recommended.  
   **Warning**: Don't ever forget the passphrases to this volume! Don't lose it (and/or do back it up to a second encrypted drive.)  
   **Protip**: store a [KeePassX](https://www.keepassx.org/) database there.
2. Sign up for a trustworthy cloud server hosting provider in a country that has a good privacy record.
   That is, [GreenQloud](http://greenqloud.com) :-)
   Or [a provider that accepts bitcoin](https://en.bitcoin.it/wiki/Virtual_private_server).
3. cd to your key storage, generate a keypair for SSH (`ssh-keygen -t rsa -f id_rsa_scsc -b 4096`) with a passphrase.
4. Send the public key to the hosting provider.  
   For GreenQloud: install [euca2ools](https://github.com/eucalyptus/euca2ools), sign in to my.greenqloud.com, User → API Access → Credentials → Download .zip, then something like this:
        
        mv ~/Downloads/gq_credentials* .
        unzip gq_credentials*
        source gq_credentials/rc
        /usr/local/bin/euca-import-keypair -f id_rsa.pub scsc
        
5. Copy the private key to your hard drive for now (because SSH can't use keys from the FAT file system): `cp id_rsa_scsc ~/.ssh/`

*It's also a good idea to set up full disk encryption on your devices.*

### Server setup

1. Create a security group, name it `scsc`, open up SSH (tcp port 22) and OpenVPN (udp port 1194).
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
   OS X: [Tunnelblick](http://code.google.com/p/tunnelblick/wiki/DownloadsEntry?tm=2)  
   Mobile: OpenVPN Connect ([iOS](https://itunes.apple.com/us/app/openvpn-connect/id590379981?mt=8), [Android](https://play.google.com/store/apps/details?id=net.openvpn.openvpn))
2. Do the following on the local machine (in the key storage directory) to get the key:
        
        ssh scsc sudo /etc/openvpn/easy-rsa/make_client_package client
        scp scsc:/home/ubuntu/client.tar.gz ./
        ssh scsc rm /home/ubuntu/client.tar.gz
        tar xvf client.tar.gz
        
3. You have the OpenVPN configuration files and keys in the `client` directory. Rename it to `client.tblk` for Tunnelblick.

### Browser setup

1. Use `privoxy.scsc:8118` as the HTTP proxy in your browser to access .i2p and .onion sites.
   Ignore the proxy for .scsc and .dev (.scsc resolves to the VPS, .dev to localhost).
   ![Firefox proxy settings screenshot](https://files.app.net/7cgckJ3L)

### Finishing

When everything works, delete the copy of the SSH key from your hard drive (`rm ~/.ssh/id_rsa_scsc`) and close port 22 (SSH) on your hosting provider's firewall (security group).

### Upgrading

To upgrade, copy the SSH key again, reopen port 22, connect to the server via SSH and run `sudo scsc-update`.

## Usage

### BitTorrent Sync and WebDAV

BitTorrent Sync is available at [btsync.scsc](http://btsync.scsc).  
Use the folder /data/files for syncing.
This is the folder that's available through WebDAV at [dav.scsc](http://dav.scsc).

### Firefox Sync

Firefox Sync (Mozilla Weave) is available at weave.scsc.  
[iCab Mobile](http://www.icab-mobile.de/) on iOS supports Firefox Sync.

### I2P

The I2P router console is available at [i2p.scsc](http://i2p.scsc).  
You need to use the HTTP proxy (see Browser setup above) to access I2P and Tor hidden services.

### Transmission

The Transmission web and remote interface is available at [transmission.scsc](http://transmission.scsc), without authentication.

## TODO

- tarsnap backup and restore
- bitcoind + coinpunk
- bitmessage + bmwrapper
- mail server
- xmpp server
- owncloud or something simpler for carddav & caldav
