# linode-fde

Scripts to kickstart a Fedora 31 Linode with Full Disk Encryption

*Not ready for prime time. Do not use.*

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
