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

# My environment

I'm on a Macbook, the scripts require curl and jq (from macports or homebrew).
My Linode token is in my MacOS keychain (so convenient!).

```
// add Linode token to MacOS keychain
% security add-generic-password -a $USER -s LI_AUTH_TOKEN -w
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
# ./init_boot <nodename>
```

The init_boot script downloads ISOLINUX from a Fedora 31 mirror,
adds the kickstart file ks.cfg, sets the boot configuration (isolinux.cfg) to simply boot ISOLINUX and process the kickstart file.  

The kickstart file ks.cfg does the following:

- create a default encrypted LVM disk configuration, with disk password 'vagrant'
- install a minimal set of packages
- set the bootloader and root passwords to 'vagrant' 
- install the "vagrant insecure public password" to /root/.ssh/authorized_keys

# Boot the instance into the Run OS config.
#
This runs a linode instance anyone can log into.  If you leave the LISH console logged in after you run init_boot and boot


Scripts to kickstart a Fedora 31 Linode with Full Disk Encryption.

The trick is to build the linode with two raw disks, a tiny one containing
a minimal boot that runs an install with a kickstart file, and the main OS disk,
onto which the kickstart file installs a full-disk-encrypted LVM based system.

The build process requires a linode type that has at least 2Gb RAM.

### Customize the config.sh file

```
% cp config.sh.sample config.sh
% vi config.sh
```

### Create the linode, with raw disks (install disk, OS disk)

```
% ./create_encrypted_linode
```

This build the machine, and boots into rescue mode.

### ssh into console, and initialize the install disk

```
# curl -OLk https://raw.githubusercontent.com/brad2014/linode-fde/master/init_boot
# sh -x init_boot
```

If you stay connected to the console while installing and running, you can watch the progress.

### Boot into install config

```
% ./reboot_linode install
```

This will run the kickstart described in the init_boot file.

### Boot into the OS

Change the various passwords from the kickstart file from "vagrant" to your own secrets:

```
% ./boot_linode run
% ./fix_passwords
```
