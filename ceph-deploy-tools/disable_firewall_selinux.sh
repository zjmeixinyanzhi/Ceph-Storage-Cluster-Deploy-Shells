#!/bin/sh
#
# Disable Firewall and SELinux

# if SELinux is enable, it should reboot
for ip in ${nodes_map[@]};
do
  sestatus=$(ssh root@$ip sestatus -v |grep "SELinux status:"|awk '{print $3}')
  flag=unknown
  if [ $sestatus = "enabled" ];then
    echo "${ip}:SELinux is enforce!Reboot now? (yes/no)"
    read flag
  else
    echo "SELinux is disabled!"
  fi
  ssh root@$ip /bin/bash << EOF
  systemctl disable firewalld.service
  systemctl stop firewalld.service
  sed -i -e "s#SELINUX=enforcing#SELINUX=disabled#g" /etc/selinux/config
  sed -i -e "s#SELINUXTYPE=targeted#\#SELINUXTYPE=targeted#g" /etc/selinux/config
  echo $flag
  if [ $flag = "yes" ];then
    echo "Reboot now!"
    reboot
  elif [ $flag = "no" ];then
    echo -e "\033[33mWARNNING:You should reboot manually! \033[0m"
  fi
EOF
  ssh root@$ip systemctl status firewalld.service|grep  Active:
  ssh root@$ip sestatus -v
done;
