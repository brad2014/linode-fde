kernel vmlinuz
append initrd=initrd.img devfs=nomount text inst.repo=https://dl.fedoraproject.org/pub/fedora/linux/releases/31/Everything/x86_64/os/ inst.ks=<%= @ks_url %>/fde.ks
