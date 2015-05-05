#!/bin/bash

# use newest repository
echo "deb http://archive.ubuntu.com/ubuntu/ vivid main restricted" > /etc/apt/sources.list.d/debootstrap.list

# update
apt-get update -qq

# install debootstrap
apt-get install -y --force-yes debootstrap

# remove repository
rm /etc/apt/sources.list.d/debootstrap.list
apt-get update -qq
