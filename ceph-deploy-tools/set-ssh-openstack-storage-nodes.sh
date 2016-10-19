#!/bin/sh
nodes_name=(${!hypervisor_map[@]});
controllers_name=(${!controller_map[@]})
echo ${controllers_name[@]}
ssh-keygen

for ((i=0; i<${#hypervisor_map[@]}; i+=1));
  do
      name=${nodes_name[$i]};
      ip=${hypervisor_map[$name]};
      echo "-------------$name------------"
      ssh-copy-id $deploy_user@$ip
      ssh-copy-id $deploy_user@$(echo $data_network|cut -d "." -f1-3).$(echo $ip|awk -F "." '{print $4}')
      ssh-copy-id $deploy_user@$(echo $store_network|cut -d "." -f1-3).$(echo $ip|awk -F "." '{print $4}')
  done;
