#!/bin/bash

# configure domU
DOMAIN_NAME=jessie
DOMAIN_MAC=00:10:01:aa:bb:cc
DOMAIN_RAM=2Gb
DOMAIN_HDD=8Gb
 
# create domU on LVM (for image file use --dir=/root)
xen-create-image \
 --hostname=${DOMAIN_NAME} \
 --dist=jessie \
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
 --vcpus $(cat /proc/cpuinfo | grep processor | wc -l) \
 --pygrub
 
# --apt_proxy=http://apt-cacher:3142/
 
# rename vm config
mv /etc/xen/${DOMAIN_NAME}.cfg /etc/xen/${DOMAIN_NAME}
 
# OPTIONAL: add to autostart
ln -s /etc/xen/${DOMAIN_NAME} /etc/xen/auto
 
# start domU
xm create -c ${DOMAIN_NAME}

# login
user: root
password: t00r

# disable pc speaker
echo 'blacklist snd-pcsp' >> /etc/modprobe.d/blacklist.conf

# fix FQDN
echo "$(ifconfig eth0| grep "inet addr" | cut -d ":" -f2 | cut -d" " -f1)     $(hostname).$(cat /etc/resolv.conf | grep domain | cut -d" " -f2) $(hostname)" >> /etc/hosts
 
# OPTIONAL: enable APT auto update
wget -q --no-check-certificate https://raw.githubusercontent.com/panticz/scripts/master/enable_auto_update.sh -O - | bash -
