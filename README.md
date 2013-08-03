# scsc – Secure Cloud Starter Kit

This thing allows you to use a cloud server for:

- file storage, sync and access ([BitTorrent Sync](http://labs.bittorrent.com/experiments/sync.html) + WebDAV), secure over OpenVPN
- more secure Internet access (your web traffic is tunnelled through your cloud server with OpenVPN, DNS queires from the server are using [DNSCrypt](http://dnscrypt.org/))
- more Internet access ([OpenNIC](http://www.opennicproject.org/) and [.bit](http://dot-bit.org/Main_Page) domains, [I2P](http://www.i2p2.de/) network, [Tor](https://www.torproject.org/) hidden services)

## Setup

### Requirements

*Use [passphrases](http://xkcd.com/936/), not passwords.
There's the [correcthorsebatterystaple.net](http://correcthorsebatterystaple.net/) generator, but if you don't trust computers, check out [Diceware Passphrase](http://world.std.com/~reinhold/diceware.html).*

1. Establish a place where you can securely store cryptographic keys.  
   A [TrueCrypt](http://www.truecrypt.org)-powered [Hidden volume](http://www.truecrypt.org/hiddenvolume) on a small partition of a USB drive or SD card is strongly recommended.  
   **Warning**: Don't ever forget the passphrases to this volume! Don't lose it (and/or do back it up to a second encrypted drive.)  
   **Note**: SSH won't use a key from the FAT file system, you have to copy it to your disk to use for installation/administration and remove the copy after use.   
   **Protip**: store a [KeePassX](https://www.keepassx.org/) database there.
2. Sign up for a trustworthy cloud server hosting provider in a country that has a good privacy record.
   That is, [GreenQloud](http://greenqloud.com) :-)
3. cd to your key storage, generate a keypair for SSH (`ssh-keygen -t rsa -f id_rsa`) with a passphrase.
4. Send the public key to the hosting provider.  
   For GreenQloud: install [euca2ools](https://github.com/eucalyptus/euca2ools), sign in to my.greenqloud.com, User → API Access → Credentials → Download .zip, then something like this:
        
        mv ~/Downloads/gq_credentials* .
        unzip gq_credentials*
        source gq_credentials/rc
        /usr/local/bin/euca-import-keypair -f id_rsa.pub scsc

*It's also a good idea to set up full disk encryption on your devices.*

### Server setup

1. Create a security group, name it `scsc`, open up SSH (tcp port 22) and OpenVPN (udp port 1194).
2. Create an instance with Ubuntu Server 12.04 LTS, the security group `scsc` and keypair `scsc`.
3. Add the instance to your `~/.ssh/config` like this
        
        Host scsc
          Hostname i-12-34-56-78.compute.is-1.greenqloud.com
          User ubuntu
          IdentityFile "/Volumes/USB DRIVE/id_rsa"
        
4. `ssh scsc`, check the fingerprint, say yes.
5. Run `curl -L https://raw.github.com/myfreeweb/scsc/master/install.sh | bash` there.
   That's the installation process.
   Some things are compiled from source, so it's not lightning fast.
   You can start installing VPN client apps while it's running.

### VPN client setup

1. Install OpenVPN clients.  
   OS X: [Tunnelblick](http://code.google.com/p/tunnelblick/wiki/DownloadsEntry?tm=2)  
   Mobile: OpenVPN Connect ([iOS](https://itunes.apple.com/us/app/openvpn-connect/id590379981?mt=8), [Android](https://play.google.com/store/apps/details?id=net.openvpn.openvpn))
2. Do the following on the local machine (in the key storage directory) to get the key:
        
        ssh scsc sudo /etc/openvpn/easy-rsa/make_client_package
        scp scsc:/home/ubuntu/client.tar.gz ./
        ssh scsc rm /home/ubuntu/client.tar.gz
        tar xvf client.tar.gz
        # The following is for Tunnelblick only:
        cp -r client client.tblk
        rm client.tblk/client.csr
        
3. Open `client.tblk` in Tunnelblick (just `client` is for other OpenVPN clients.)
4. Copy all files inside `client` to your mobile devices for OpenVPN Connect (for iOS that means syncing via iTunes.)

### Browser setup

1. Use `privoxy.scsc:8118` as the HTTP proxy in your browser to access .i2p and .onion sites.

## TODO

- tarsnap backup and restore
- bitcoind + coinpunk
- bitmessage + bmwrapper
- mail server
- xmpp server
- owncloud or something simpler for carddav & caldav
- [firefox sync](http://docs.services.mozilla.com/howtos/run-sync.html)
