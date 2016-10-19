#!/bin/sh
nodes_name=(${!hypervisor_map[@]});

base_location=$ftp_info
deploy_node=compute01
echo $deploy_node

ceph-deploy forgetkeys
ceph-deploy purge  ${nodes_name[@]}
ceph-deploy purgedata   ${nodes_name[@]}

for ((i=0; i<${#hypervisor_map[@]}; i+=1));
  do
      name=${nodes_name[$i]};
      ip=${hypervisor_map[$name]};
      echo "-------------$name------------"
        ssh root@$name  rm -rf $osd_path/*
  done;


osds="";
echo $osds

### set
for ((i=0; i<${#hypervisor_map[@]}; i+=1));
  do
      name=${nodes_name[$i]};
      ip=${hypervisor_map[$name]};
      echo "-------------$name------------"
	osds=$osds" "$name":"$osd_path
        ssh root@$name  chown -R ceph:ceph $osd_path
  done;
echo $osds
#cp 0-set-config.sh /home/$deploy_user/
su - $deploy_user <<HERE
echo $osds
#. /home/$deploy_user/0-set-config.sh  
mkdir -p ~/my-cluster
cd ~/my-cluster
rm -rf ~/my-cluster/*
ceph-deploy new $deploy_node
echo "public network ="$local_network>>ceph.conf
echo "cluster network ="$store_network>>ceph.conf
ceph-deploy install --nogpgcheck --repo-url $base_location/download.ceph.com/rpm-$ceph_release/el7/ ${nodes_name[@]} --gpg-url $base_location/download.ceph.com/release.asc
ceph-deploy mon create-initial
###[部署节点]激活OSD
ceph-deploy osd prepare $osds
ceph-deploy osd activate $osds
ceph-deploy admin ${nodes_name[@]}

#rm -rf /home/$deploy_user/0-set-config.sh 
HERE
### set
for ((i=0; i<${#hypervisor_map[@]}; i+=1));
  do
      name=${nodes_name[$i]};
      ip=${hypervisor_map[$name]};
      echo "-------------$name------------"
        if [ $name =  $deploy_node ]; then
          echo $name" already is mon!"
        else
          su - $deploy_user -c "cd ~/my-cluster;ceph-deploy mon add $name"
        fi
  done;

###查看集群状态
ceph -s
###[ceph管理节点]创建Pool
ceph osd pool create volumes 128
ceph osd pool create images 128
ceph osd pool create backups 128
ceph osd pool create vms 128
