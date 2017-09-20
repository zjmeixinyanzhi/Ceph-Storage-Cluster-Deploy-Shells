#!/bin/sh
nodes_name=(${!nodes_map[@]});
blk_name=(${!blks_map[@]});
monitor_name=(${!monitors_map[@]});
### 获取OSD信息，用于生成并激活OSD
osds="";
for host in ${!nodes_map[@]};
do
  for disk in ${blks_map[@]}
  do
    osds=$osds" "$host":"$disk;
  done
done

### 获取Monitor信息，用于生成ceph配置文件
mon_hostname=""
mon_ip=""
### set mon nodes
for ((i=0; i<${#monitors_map[@]}; i+=1));
do
 name=${monitor_name[$i]};
 ip=${nodes_map[$name]};
 if [ $name = $deploy_node ]; then
 echo $name" already is mon!"
 else
 mon_hostname=$mon_hostname","$name
 mon_ip=$mon_ip","$ip
 fi
done;
echo $osds
echo $mon_hostname
echo $mon_ip

mkdir -p /root/my-cluster
cd /root/my-cluster
rm -rf /root/my-cluster/*
ceph-deploy new $deploy_node
sed -i -e 's#'"$( cat /root/my-cluster/ceph.conf |grep mon_initial_members)"'#'"$( cat /root/my-cluster/ceph.conf |grep mon_initial_members)$mon_hostname"'#g' /root/my-cluster/ceph.conf
sed -i -e 's#'"$( cat /root/my-cluster/ceph.conf |grep mon_host )"'#'"$(  cat /root/my-cluster/ceph.conf |grep mon_host )$mon_ip"'#g' /root/my-cluster/ceph.conf
echo "public network = "$public_net >> /root/my-cluster/ceph.conf
echo "cluster network = "$storage_net >> /root/my-cluster/ceph.conf
ceph-deploy install ${nodes_name[@]}
ceph-deploy mon create-initial
ceph-deploy osd create $osds
ceph-deploy admin ${nodes_name[@]}
### Add mon nodes
for ((i=0; i<${#monitor_map[@]}; i+=1));
do
  name=${monitor_name[$i]};
  ip=${monitor_map[$name]};
  echo "Set $name as a ceph monitor" 
  if [ $name =  $deploy_node ]; then
    echo $name" already is mon!"
  else
    cd /root/my-cluster
    ceph-deploy mon add $name
  fi
done;
### Update ceph.conf
ceph-deploy --overwrite-conf config push ${nodes_name[@]}
ceph -s

