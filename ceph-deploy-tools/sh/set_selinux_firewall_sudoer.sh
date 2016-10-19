#!/bin/sh
deploy_user=$1
password_deploy_user=$2
### add ceph-deploy user
echo $password_deploy_user
useradd -d /home/$deploy_user -p $password_deploy_user $deploy_user
(echo $password_deploy_user
sleep 1
echo $password_deploy_user)|passwd $deploy_user

chmod 755 /etc/sudoers.d
echo "$deploy_user ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$deploy_user
su - $deploy_user <<HERE
sudo chmod 0440 /etc/sudoers.d/$deploy_user
sudo ls -l  /etc/sudoers.d/$deploy_user 
HERE
### disable firewall
systemctl disable firewalld.service
systemctl stop firewalld.service
### disable selinux
sed -i -e "s#SELINUX=enforcing#SELINUX=disabled#g" /etc/selinux/config
sed -i -e "s#SELINUXTYPE=targeted#\#SELINUXTYPE=targeted#g" /etc/selinux/config
###set ceph ssh
sed -i -e 's#Defaults   *requiretty#Defaults:ceph !requiretty#g' /etc/sudoers
