#!/bin/bash

# configure domU
DOMAIN_NAME=wheezy
DOMAIN_MAC=00:10:01:01:aa:bb
DOMAIN_RAM=2Gb
DOMAIN_HDD=8Gb
 
# create domU on LVM (for image file use --dir=/root)
xen-create-image \
 --hostname=${DOMAIN_NAME} \
 --dist=wheezy \
 --lvm=vg0 \
 --size=${DOMAIN_HDD} \
 --fs=ext4 \
 --role=udev \
 --memory=${DOMAIN_RAM} \
 --swap=${DOMAIN_RAM} \
 --dhcp \
 --mac=${DOMAIN_MAC} \
 --genpass=0 \
 --password=t00r \
 --apt_proxy=http://apt-cacher:3142/ \
 --vcpus $(cat /proc/cpuinfo | grep processor | wc -l)
 
# rename vm config
mv /etc/xen/${DOMAIN_NAME}.cfg /etc/xen/${DOMAIN_NAME}
 
# OPTIONAL: add to autostart
ln -s /etc/xen/${DOMAIN_NAME} /etc/xen/auto
 
# start domU
xm create -c ${DOMAIN_NAME}

# disable pc speaker
echo 'blacklist snd-pcsp' >> /etc/modprobe.d/blacklist.conf

# fix FQDN
sed -i "s|$(hostname) $(hostname)|$(hostname -A)$(hostname)|g" /etc/hosts
 
user: root
password: t00r
