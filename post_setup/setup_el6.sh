#!/bin/bash

# install epel
ret=1
while [ $ret -ne 0 ];do yum install -y http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm;ret=$?;echo $ret;sleep 2;done

# install puppet 
ret=1
while [ $ret -ne 0 ];do rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-el-6.noarch.rpm;ret=$?;echo $ret;sleep 2;done
yum install -y puppet

# update the system
yum -y distro-sync

# get linux rootfs resize
cd /tmp
ret=1
while [ $ret -ne 0 ];do rm -rf linux-rootfs-resize;git clone git://github.com/efattibene/linux-rootfs-resize.git;ret=$?;echo $ret;sleep 2;done

# install cloud-init packages
ret=1
while [ $ret -ne 0 ];do yum install -y cloud-utils cloud-init parted;ret=$?;echo $ret;sleep 2;done

# enable sudo for users in group "wheel"
sed -i 's/#\s%wheel\sALL=(ALL)\sNOPASSWD: ALL/ %wheel\t\tALL=(ALL)\tNOPASSWD: ALL/g' /etc/sudoers

# enable user "cloud-user" for sudo
echo "cloud-user    ALL=(ALL)       NOPASSWD: ALL">>/etc/sudoers

# install linux rootfs resize
cd /tmp/linux-rootfs-resize/
./install

# set eth0 interface
echo -e "TYPE=Ethernet\nDEVICE=eth0\nONBOOT=yes\nBOOTPROTO=dhcp\nNM_CONTROLLED=no">/etc/sysconfig/network-scripts/ifcfg-eth0

echo "NOZERCONF=yes">>/etc/sysconfig/network

# setup cloud-init config
sed -i -e '/cloud_init_modules:/a\ - resolv-conf' /etc/cloud/cloud.cfg

# remove net files
rm /etc/udev/rules.d/70-persistent-net.rules
rm /lib/udev/rules.d/75-net-description.rules

touch /etc/udev/rules.d/70-persistent-net.rules
touch /lib/udev/rules.d/75-net-description.rules

chattr +i /etc/udev/rules.d/70-persistent-net.rules
chattr +i /lib/udev/rules.d/75-net-description.rules

