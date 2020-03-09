install
text
network --bootproto=dhcp --ipv6=auto --activate
keyboard --vckeymap=us --xlayouts='us'
lang en_US.UTF-8
timezone America/Los_Angeles --isUtc
firstboot --disable
skipx
zerombr
bootloader --location=mbr --password=changeme
clearpart --all --initlabel
autopart --type=lvm --encrypted --passphrase=changeme
rootpw changeme
reboot --eject

%packages --ignoremissing
@core
%end
