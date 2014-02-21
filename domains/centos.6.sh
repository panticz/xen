#!/bin/bash

#
# TODO
# use separate partitions for root (/dev/vg0/centos6-disk) and swap (/dev/vg0/centos6-swap) instead of harddisk image

# create disk
lvcreate --name centos6-disk --size 8G vg0

# download installation kernel and initrd
[ -d /tmp/centos6 ] || mkdir /tmp/centos6
wget -q http://mirror.netcologne.de/centos/6/os/x86_64/images/pxeboot/initrd.img -O /tmp/centos6/initrd.img
wget -q http://mirror.netcologne.de/centos/6/os/x86_64/images/pxeboot/vmlinuz -O /tmp/centos6/vmlinuz

# create installation configuration
cat <<EOF> /tmp/centos6-inst
kernel      = '/tmp/centos6/vmlinuz'
ramdisk     = '/tmp/centos6/initrd.img'
memory      = '512'
disk        = [ 'phy:/dev/vg0/centos6-disk,xvda,w' ]
name        = 'centos6-inst'
dhcp        = 'dhcp'
vif         = [ 'mac=00:00:00:00:ce:ce' ]
on_poweroff = 'destroy'
on_reboot   = 'destroy'
on_crash    = 'destroy'
extra       = "text ip=dhcp ks=http://preseed.panticz.de/preseed/centos6-minimal.cfg"
EOF

# install
xm create -c /tmp/centos6-inst

# create CenOS 6 configuration
cat <<EOF> /etc/xen/centos6
bootloader  = "/usr/lib/xen-4.1/bin/pygrub"
memory      = '512'
disk        = [ 'phy:/dev/vg0/centos6-disk,xvda,w' ]
name        = 'centos6'
dhcp        = 'dhcp'
vif         = [ 'mac=00:00:00:00:ce:ce' ]
on_poweroff = 'destroy'
on_reboot   = 'restart'
on_crash    = 'restart'
EOF

# OPTIONAL: add to autostart
ln -s /etc/xen/centos6 /etc/xen/auto/centos6

# start CenOS 6
xm create -c centos6
