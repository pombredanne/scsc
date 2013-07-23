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
7. Add the instance to your `~/.ssh/config` like this
        
        Host scsc
          Hostname i-12-34-56-78.compute.is-1.greenqloud.com
          User ubuntu
          IdentityFile "/Volumes/USB DRIVE/id_rsa"
        
8. `ssh scsc`, trust the fingerprint
9. Run `curl -L https://raw.github.com/myfreeweb/scsc/master/install.sh | bash` there
10. Install an OpenVPN client (OS X: [Tunnelblick](http://code.google.com/p/tunnelblick/wiki/DownloadsEntry?tm=2)) while you're waiting.
11. When it's done, do the following on the local machine (in the key storage directory)
        
        ssh scsc sudo /etc/openvpn/easy-rsa/make_client_package
        scp scsc:/home/ubuntu/client.tar.gz ./
        ssh scsc rm /home/ubuntu/client.tar.gz
        tar xvf client.tar.gz
        cp -r client client.tblk
        rm client.tblk/client.csr
        
12. Open client.tblk in Tunnelblick, connect.
13. Use privoxy.scsc:8118 as the HTTP proxy in your browser to access .i2p.

## TODO

- tor via privoxy for .onion sites + proxy setting to use for all sites
- tarsnap backup and restore
- bitcoind + coinpunk
- bitmessage + bmwrapper
- mail server
- xmpp server
- owncloud or something simpler for carddav & caldav
- [firefox sync](http://docs.services.mozilla.com/howtos/run-sync.html)
