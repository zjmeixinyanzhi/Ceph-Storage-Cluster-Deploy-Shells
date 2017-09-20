#!/bin/sh
#
# NTP: chrony configuration,
# chrony sources will be write in result.log
declare nodes_name=(${!nodes_map[@]})
for ((i=0; i<${#nodes_map[@]}; i+=1));
do
  name=${nodes_name[$i]};
  ip=${nodes_map[$name]};
  if [[ $name = $deploy_node ]];then
    echo ""$ip
    sed -i -e '/server [0 1 2 3].centos.pool.ntp.org/d'  /etc/chrony.conf
    sed -i -e "s#\#local stratum#local stratum#g" /etc/chrony.conf
    echo "allow "$public_net >>/etc/chrony.conf
  else
    ssh root@$ip /bin/bash <<EOF
    sed -i -e 's#server 0.centos.pool.ntp.org#server '"$ntp_server"'#g'  /etc/chrony.conf
    sed -i -e '/server [0 1 2 3].centos.pool.ntp.org/d'  /etc/chrony.conf
EOF
  fi
  ssh root@$ip systemctl enable chronyd.service
  ssh root@$ip systemctl restart chronyd.service
  ssh root@$ip cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
done;
pssh -i -h ./hosts/nodes.txt "date +%z"
pssh -i -h ./hosts/nodes.txt "chronyc sources"
