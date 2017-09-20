#!/bin/sh
#
# SSH configuration to others nodes
ssh-keygen
for host in ${nodes_map[@]};
do
  ssh-copy-id root@$host
done
# Install pssh
installed=$(rpm -qa|grep "pssh")
### Check pssh is installed
if [[ -z "$installed" ]];then
  yum install -y pssh
fi
# Test pssh
pssh -i -h ./hosts/nodes.txt hostname
