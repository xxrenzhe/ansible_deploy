#!/bin/bash
#
# Funtion : pre deployment before managed by ansible control server
# Author : Jason.Yu
# CTime : 2014.07.16

###### Add a new user:wenba ######
add_user() {
    if id $User &>/dev/null;then
	ret=0
    	echo -ne "\033[35mUser $User alreay exists...\033[0m"
	ret=$?
	[ $ret -eq 0 ] && success || failure	
	echo
    else
	ret=0
    	echo -ne "\033[35mAdding user $User...\033[0m"
    	/usr/sbin/groupadd $User
    	/usr/sbin/useradd -g $User -G wheel $User
	ret=$?
	[ $ret -eq 0 ] && success || failure	
	echo
    fi

    ret=0
    echo -ne "\033[35mChanging password for user $User...\033[0m" 
    echo "$Password" | /usr/bin/passwd --stdin $User &>/dev/null 
    ret=$?
    [ $ret -eq 0 ] && success || failure	
    echo

    ret=0
    echo -ne "\033[35mAdding user $User tyo group wheel...\033[0m" 
    sed -i 's/^#\s\+\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)/\1/p' /etc/sudoers 
    ret=$?
    [ $ret -eq 0 ] && success || failure	
    echo
}

###### Deploy Control SSH Public Key into wenba's authorized_keys ######
add_ssh_key() {
    Ipaddr=`ifconfig |grep -A 1 eth0|grep "inet addr"|awk '{print $2}'|awk -F':' '{print $2}'`
    [[ ! -e /home/wenba/.ssh/authorized_keys ]] && ssh wenba@$Ipaddr 'ssh-keygen'

    ret=0
    echo -ne "\033[35mAdding Final-Control SSH public key...\033[0m"
    echo $Final_Control_key >> /home/wenba/.ssh/authorized_keys 
    ret=$?
    [ $ret -eq 0 ] && success || failure	
    echo

    ret=0
    echo -ne "\033[35mAdding Ansible-Control SSH public key...\033[0m"
    echo $Ansible_Control_key >> /home/wenba/.ssh/authorized_keys 
    ret=$?
    [ $ret -eq 0 ] && success || failure	
    echo

}

main() {
    echo -e "\033[37m===============\033[0m\033[33mStarting to initialize the server\033[0m\033[37m==============\033[0m"

    # source function library
    . /etc/rc.d/init.d/functions
   
    User="wenba"
    Password="xxoo"
    Final_Control_key="xxoo"
    Ansible_Control_key="xxoo"

    add_user
    add_ssh_key
}

main
