#!/bin/sh
nodes_name=(${!nodes_map[@]});
###清理ceph安装数据
ceph-deploy forgetkeys
ceph-deploy purge  ${nodes_name[@]}
ceph-deploy purgedata   ${nodes_name[@]}
