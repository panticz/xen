#!/bin/bash

# use newest repository
echo "deb http://archive.ubuntu.com/ubuntu/ xenial main restricted" > /etc/apt/sources.list.d/debootstrap.list

# update
apt-get update -qq

# install debootstrap
apt-get install -y --force-yes debootstrap

# remove repository
rm /etc/apt/sources.list.d/debootstrap.list
apt-get update -qq

# create template links
cd /usr/lib/xen-tools/
[ ! -f  lucid.d ] && ln -s karmic.d lucid.d
[ ! -f  maverick.d ] && ln -s karmic.d maverick.d
[ ! -f  natty.d ] && ln -s karmic.d natty.d
[ ! -f  oneiric.d ] && ln -s karmic.d oneiric.d
[ ! -f  precise.d ] && ln -s karmic.d precise.d
[ ! -f  quantal.d ] && ln -s karmic.d quantal.d
[ ! -f  raring.d ] && ln -s karmic.d raring.d
[ ! -f  trusty.d ] && ln -s karmic.d trusty.d
[ ! -f  trusty.d ] && ln -s karmic.d xenial.d
[ ! -f jessie.d ] && ln -s debian.d jessie.d
