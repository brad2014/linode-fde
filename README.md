# linode-fde

Here are my notes on creating a Fedora 31 Linode with Full Disk Encryption (FDE).

The TL;DR

```
% cp config.sh.sample config.sh
% vi config.sh
% ./create_encrypted_linode
% ssh -t <lishconsole> <nodename>
# curl -OLk https://raw.githubusercontent.com/brad2014/linode-fde/master/init_boot
# sh -x init_boot
% ./boot_lindode install
% ./boot_lindode run
% ./fix_passwords
```

# Why would anyone want to do this?

It's a good question. The keys to decrypt the disk are in memory
on the host in an "unsafe" place (at the cloud company).  However,
we feel that because it is essentially impossible to erase data
written to an SSD, that disks should always be encrypted.  To the
extent that we can sucessfully erase/efface the key from memory (on
shutdown or destruction), the data is thereafter fairly inaccessible
to non-targeted attacks.

Of course, the usual caveats apply — know your threat model.
Obviously: Anyone with access to your machine (presumably, anyone
inside the colo) can read your disks while the machine is running.
Anyone with root access can add their own decryption key.  If you
put a key in a file on the boot partition, to allow unattended boot,
then anyone with machine access has the key (we still think this
has a use case, since it protects discarded disks from trawlers).

The main use case seems to be to prevent random scans of the raw
disk from non-targeted fishing expeditions.

But I could be wrong.  Anyone, it was a fun experiment.

# My environment

I'm on a Macbook, the scripts require curl and jq (from macports or homebrew).
My Linode token is in my MacOS keychain (so convenient!).

```
// add Linode token to MacOS keychain
% security add-generic-password -a $USER -s LI_CLOUD_AUTH_TOKEN -w
<paste in the Linode cloud api token>
```

# Breaking it down

## config.sh

Set the token, region, hostname, and node type (which determines CPU, RAM and disk sizes).  The hostname is also used for the instance label.

## create_encrypted_linode

This script, run on my local machine, does the following steps:

- Destroy the existing hostname instance, if it exists
- Create a new instance with that hostname/type/region
- Create a 100Mb "Install" disk (which will contain a minimal isolinux boot system and a kickstart file)
- Use the rest of the space to create an "OS" disk for the FDE installation.
- Create an "Install" configuration. Root / is mounted from /dev/sdb which is assigned to the Install disk. /dev/sda is assigned to the raw OS disk, to receive the installation.
- Create a "Run OS" configuration which boots off the OS disk (once it has been installed). Root / is mounted from /dev/sda which is assigned from the OS disk.
- Boot into rescue mode, to initialize the install disk.

## Initialize the Install disk

FIXME: I wish I could do this via scp and ssh from my local machine to the rescue system, but I couldn't figure out how to do that.  So I ssh into the LISH terminal connected to the rescue machine, and work from the linode console.

```
% ssh -t <lishconsole> <nodename>
# curl -OLk https://raw.githubusercontent.com/brad2014/linode-fde/master/init_boot
# sh ./init_boot <nodename>
```

The init_boot script downloads ISOLINUX from a Fedora 31 mirror,
adds the kickstart file ks.cfg, sets the boot configuration (isolinux.cfg) to simply boot ISOLINUX and process the kickstart file.  

The kickstart file ks.cfg does the following:

- create a default encrypted LVM disk configuration, with disk password 'vagrant'
- install a minimal set of packages
- set the bootloader and root passwords to 'vagrant' 
- install the "vagrant insecure public password" to /root/.ssh/authorized_keys

# Boot the instance into the Run OS config

This runs a linode instance anyone can log into.  Leave the LISH console logged in after you run init_boot and boot, so you can see what's going on.

## Boot into install config

```
% ./reboot_linode install
```

This will run the kickstart described in the init_boot file.

### Boot into the OS

Reboot into the "run" config in order to run the newly installed OS.  Make sure you have the console open when you reboot the machine, since you'll have to enter the disk password as it boots.  The password is initially "vagrant".

Then, change the various passwords from the kickstart file from "vagrant" to your own secrets:

```
% ./reboot_linode run
(on the console, enter the disk password)
% ./fix_passwords
```
