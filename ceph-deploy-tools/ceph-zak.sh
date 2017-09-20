#!/bin/sh
nodes_name=(${!nodes_map[@]});
blk_name=(${!blks_map[@]});
###安装前所有OSD盘重置为裸盘
for ((i=0; i<${#nodes_map[@]}; i+=1));
do
 name=${nodes_name[$i]};
 ip=${nodes_map[$name]};
 echo $name:$ip
 for ((j=0; j<${#blks_map[@]}; j+=1));
 do
 name2=${blk_name[$j]};
 blk=${blks_map[$name2]};
 ssh root@$ip ceph-disk zap /dev/$blk
 ssh root@$ip partprobe
 done
done
