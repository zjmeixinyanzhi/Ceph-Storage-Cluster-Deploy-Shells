#!/bin/sh

nodes_name=(${!nodes_map[@]});

deploy_node=compute01
echo $deploy_node


cd /root/my-cluster
for ((i=0; i<${#hypervisor_map[@]}; i+=1));
  do
      name=${nodes_name[$i]};
      ip=${hypervisor_map[$name]};
      echo "-------------$name------------"
        ssh root@$name  rm -rf $osd_path/*
  done;
