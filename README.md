# scsc – Secure Cloud Starter Kit

This project allows you to use a cloud server for:

- file storage, sync and access ([BitTorrent Sync](http://labs.bittorrent.com/experiments/sync.html) + WebDAV), secure over OpenVPN
- more secure Internet access (your web traffic is tunnelled through your cloud server with OpenVPN, DNS queires from the server are using [DNSCrypt](http://dnscrypt.org/))
- more Internet access ([OpenNIC](http://www.opennicproject.org/) and [.bit](http://dot-bit.org/Main_Page) domains, [I2P](http://www.i2p2.de/) network, [Tor](https://www.torproject.org/) hidden services)

## Installation

1. Establish a place where you can securely store cryptographic keys.  
   [TrueCrypt](http://www.truecrypt.org) with [Hidden volume](http://www.truecrypt.org/hiddenvolume) on a small partition of a USB drive or SD card is strongly recommended.  
   Get a second drive, make the same kind of partition, backup the original one there after setup is completed.  
   **Requirement**: Don't ever forget the password to this volume!  
   **Note**: SSH won't use a key from the FAT file system, you have to copy it to your disk to use for installation/administration and remove the copy after use.   
   **Protip**: store a [KeePassX](https://www.keepassx.org/) database of passwords there.
   Yes, even if you're usually using something like 1Password, make a KeePassX database for scsc-related passwords.
2. Sign up for a cloud server hosting provider.
   [GreenQloud](http://greenqloud.com) is strongly recommended.
3. cd to your key storage, generate a keypair for SSH (`ssh-keygen -t rsa -f id_rsa`) with a passphrase.
4. Send the public key to the hosting provider.  
   For GreenQloud: install [euca2ools](https://github.com/eucalyptus/euca2ools), sign in to my.greenqloud.com, User → API Access → Credentials → Download .zip, then something like this:
        
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
        
8. `ssh scsc`, check the fingerprint, say yes.
9. Run `curl -L https://raw.github.com/myfreeweb/scsc/master/install.sh | bash` there.
   That's the installation process.
   Some things are compiled from source, so it's not lightning fast.
10. Install an OpenVPN client (OS X: [Tunnelblick](http://code.google.com/p/tunnelblick/wiki/DownloadsEntry?tm=2)) while you're waiting.
11. When it's done, do the following on the local machine (in the key storage directory)
        
        ssh scsc sudo /etc/openvpn/easy-rsa/make_client_package
        scp scsc:/home/ubuntu/client.tar.gz ./
        ssh scsc rm /home/ubuntu/client.tar.gz
        tar xvf client.tar.gz
        # The following is for Tunnelblick only:
        cp -r client client.tblk
        rm client.tblk/client.csr
        
12. Open `client.tblk` in Tunnelblick (just `client` is for other OpenVPN clients), connect.
13. Use `privoxy.scsc:8118` as the HTTP proxy in your browser to access .i2p and .onion sites.

## TODO

- tarsnap backup and restore
- bitcoind + coinpunk
- bitmessage + bmwrapper
- mail server
- xmpp server
- owncloud or something simpler for carddav & caldav
- [firefox sync](http://docs.services.mozilla.com/howtos/run-sync.html)
