#!/bin/sh
### 设置部署节点主机名和IP，并指定monitor节点 
declare -A nodes_map=(["admin"]="192.168.2.100" ["node1"]="192.168.2.101" ["node2"]="192.168.2.102" ["node3"]="192.168.2.103");
declare -A monitors_map=(["admin"]="192.168.2.100" ["node1"]="192.168.2.101" ["node2"]="192.168.2.102");
### 后期需要增加的计算节点
declare -A additional_nodes_map=(["node4"]="192.168.2.104");
### 存储节点上OSD数据盘,所有节点数据个数及盘符一致
declare -A blks_map=(["osd01"]="sdb" ["osd02"]="sdc");
### 设置网络网段信息，分别对应管理网、存储网
public_net=192.168.2.0/24
storage_net=10.10.10.0/24
### 安装源URL 
yum_baseurl=http://download.ceph.com/rpm-jewel/el7/noarch
#yum_baseurl=ftp://192.168.100.81/pub/download.ceph.com/rpm-jewel/el7/noarch
### 部署节点主机名
deploy_node=admin
### NTP参考主机
ntp_server=admin
