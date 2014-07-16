#!/bin/bash
#
# Funtion : pre deployment before managed by ansible control server
# Author : Jason.Yu
# CTime : 2014.07.16

###### Add a new user:wenba ######
User="wenba"
Password="xxoo"

/usr/sbin/groupadd $User
/usr/sbin/useradd -g $User -G wheel $User
echo "$Password" | /usr/bin/passwd --stdin $User

sed -i 's/^#\s\+\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)/\1/p' /etc/sudoers

###### Deploy Control SSH Public Key into wenba's authorized_keys ######
Ipaddr=`ifconfig |grep -A 1 eth0|grep "inet addr"|awk '{print $2}'|awk -F':' '{print $2}'`
ssh wenba@$Ipaddr 'ssh-keygen'
echo "${control ssh public key}" > /home/wenba/.ssh/authorized_keys
echo "${ansible control server ssh public key}" >> /home/wenba/.ssh/authorized_keys
