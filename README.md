# scsc – Secure Cloud Starter Kit

This project allows you to use a cloud server for:

- file storage, sync and access ([BitTorrent Sync](http://labs.bittorrent.com/experiments/sync.html) + WebDAV), secure over OpenVPN
- more secure Internet access (traffic is tunnelled with OpenVPN, so your ISP sees nothing, websites see your server's IP)
- more Internet access ([OpenNIC](http://www.opennicproject.org/) and [.bit](http://dot-bit.org/Main_Page) domains, [I2P](http://www.i2p2.de/) network)

## Installation
1. Establish a place where you can securely store cryptographic keys. [TrueCrypt](http://www.truecrypt.org) with [Hidden volume](http://www.truecrypt.org/hiddenvolume) on a small partition of a USB drive is strongly recommended. *Note: DO NOT USE THE FAT FILESYSTEM for this partition, it doesn't store file permissions, SSH won't use a key from it.*
2. Sign up for a cloud server hosting provider. [GreenQloud](http://greenqloud.com) is strongly recommended.
3. cd to your key storage, generate a keypair for SSH (`ssh-keygen -t rsa -f id_rsa`) with empty passphrase.
4. Send the public key to the hosting provider. For GreenQloud: install [euca2ools](https://github.com/eucalyptus/euca2ools), sign in to my.greenqloud.com, User → API Access → Credentials → Download .zip, then something like this:
        
        mv ~/Downloads/gq_credentials* .
        unzip gq_credentials*
        source gq_credentials/rc
        /usr/local/bin/euca-import-keypair -f id_rsa.pub scsc
        
5. Create a security group, name it `scsc`, open up SSH (tcp port 22) and OpenVPN (udp port 1194).
6. Create an instance with Ubuntu Server 12.04 LTS, the security group `scsc` and keypair `scsc`.
7. `gem install knife-solo` (and `rbenv rehash` if you use rbenv)
8. Add the instance to your `~/.ssh/config` like this
        
        Host scsc
          Hostname i-12-34-56-78.compute.is-1.greenqloud.com
          User ubuntu
          IdentityFile "/Volumes/USB DRIVE/id_rsa"
        
9. `ssh scsc`, trust the fingerprint, log out (Ctrl+D)
10. Clone this repo (or download and unzip), cd to it, run `knife solo bootstrap scsc`, wait.
11. Install [Tunnelblick](http://code.google.com/p/tunnelblick/wiki/DownloadsEntry?tm=2) while you're waiting.
12. cd back to the key storage, do the following
        
        ssh scsc sudo /etc/openvpn/easy-rsa/make_client_package
        scp scsc:/home/ubuntu/client.tar.gz
        ssh scsc rm /home/ubuntu/client.tar.gz
        tar xvf client.tar.gz
        cp -r client client.tblk
        rm client.tblk/client.csr
        
13. Open client.tblk in Tunnelblick, connect.

## TODO

- installation without local ruby gems, just running a script on the server via ssh
- explain privoxy settings
- tor via privoxy for .onion sites + proxy setting to use for all sites
- tarsnap backup and restore
- welcome page + web settings
- truecrypt hidden folder on the server
- bitcoind + coinpunk
- namecoind + local bind9 for .bit domains
- bitmessage + bmwrapper
- mail server
- xmpp server
- owncloud or something simpler for carddav & caldav
- [forward](https://forwardhq.com)-like script