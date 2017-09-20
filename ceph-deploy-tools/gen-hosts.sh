#!/bin/sh
#
# create hosts file for pssh
. 0-set-config.sh
mkdir hosts
> hosts/nodes.txt

for ip in ${nodes_map[@]};
do
  echo "$ip" >> hosts/nodes.txt
done;
