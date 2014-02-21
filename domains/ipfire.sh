#!/bin/bash

#URL=http://downloads.ipfire.org/releases/ipfire-2.x/2.13-core73/ipfire-2.13.xen.i586-full-core73.tar.bz2

# get ipfire xen image
#wget ${URL} -P /tmp/

# extract
#tar xjf /tmp/ipfire-2.*.xen.i586-full-core*.tar.bz2 -C /tmp/

# new version
wget -q http://downloads.ipfire.org/releases/ipfire-2.x/2.13-core75/ipfire-2.13.xen.i586-downloader-core75.tar.bz2 -O - | tar -C /tmp -xjf -
bash /tmp/ipfire/xen-image-maker.sh

# fix kernel name and Xen 4.x console output 
mount /root/ipfire-boot.img /mnt/
sed -i 's|vmlinuz-3.2.48-ipfire-xen|vmlinuz-3.2.48-ipfire-pae|g' /mnt/grub/grub.conf
sed -i 's| console=xvc0||g' /mnt/grub/grub.conf
umount /mnt

# fix Xen 4.x console output
mount /root/ipfire-root.img /mnt/
sed -i 's|xvc0|hvc0|g' /mnt/etc/inittab
sed -i 's|xvc0|hvc0|g' /mnt/etc/securetty
umount /mnt

# copy data to lv
mkdir -p /tmp/ipfire/mnt/

# copy boot filesystem
lvcreate --name fw-boot --size 256M vg0
mkfs.ext2 /dev/vg0/fw-boot
#mount /tmp/ipfire/ipfire-boot.img /tmp/ipfire/mnt/ -o loop
mount ipfire-boot.img /tmp/ipfire/mnt/
mount /dev/vg0/fw-boot /mnt/
cp -a  /tmp/ipfire/mnt/* /mnt/
umount /tmp/ipfire/mnt/
umount /mnt/

# copy root filesystem
lvcreate --name fw-root --size 2G vg0
mkfs.ext4 /dev/vg0/fw-root
#mount /tmp/ipfire/ipfire-root.img /tmp/ipfire/mnt/ -o loop
mount ipfire-root.img /tmp/ipfire/mnt/
mount /dev/vg0/fw-root /mnt/
cp -a  /tmp/ipfire/mnt/* /mnt/
umount /tmp/ipfire/mnt/
umount /mnt/

# copy var filesystem
lvcreate --name fw-var --size 2G vg0
mkfs.ext4 /dev/vg0/fw-var
#mount /tmp/ipfire/ipfire-var.img /tmp/ipfire/mnt/ -o loop
mount ipfire-var.img /tmp/ipfire/mnt/
mount /dev/vg0/fw-var /mnt/
cp -a  /tmp/ipfire/mnt/* /mnt/
umount /tmp/ipfire/mnt/
umount /mnt/

# create swap
lvcreate --name fw-swap --size 1G vg0
mkswap /dev/vg0/fw-swap


# clean up
rm -r /tmp/ipfire*

# create xen config file
cat <<EOF> /etc/xen/fw
#bootloader = '/usr/lib/xen-default/bin/pygrub'
bootloader = '/usr/lib/xen-4.1/bin/pygrub'
memory = 512
name = "fw"
acpi = 1
apic = 1
vif = [ 'mac=00:17:4e:be:b1:ba' ]
disk = [
    'phy:/dev/vg0/fw-boot,xvda1,w',
    'phy:/dev/vg0/fw-swap,xvda2,w',
    'phy:/dev/vg0/fw-root,xvda3,w',
    'phy:/dev/vg0/fw-var,xvda4,w'
]
acpi=1
apic=1
pci = ['00:0c.0']
extra = 'iommu=soft'
EOF

# OPTIONAL: autostart
ln -s /etc/xen/fw /etc/xen/auto/01_fw

# TODO (automate)
rmmod e100
rmmod xen-pciback
modprobe xen-pciback 'hide=(00:0c.0)'
xm pci-list-assignable-devices

# start domU
xm create -c fw
