# linode-fde

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

### Boot into install config

This will run the kickstart described in the init_boot file.

### Boot into the OS

Change the various passwords from the kickstart file from "changeme" to your own secrets:

```
# grub2-setpassword
# passwd
# cryptsetup luksChangeKey $(cut -f2 -d' ' /etc/crypttab)
```
