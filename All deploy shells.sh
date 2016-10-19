
 #####################################################
 ########          安装配置文件           ############
 #####################################################

 
###*******0-set-config.sh **********####
 
#!/bin/sh
declare -A hypervisor_map=(["compute01"]="192.168.2.14" ["compute02"]="192.168.2.15" ["compute03"]="192.168.2.16");

### 设置网络网段信息，分别对应管理网、虚拟网、存储网
local_network=192.168.2.0/24
data_network=10.10.10.0/24
store_network=11.11.11.0/24

### 离线安装源的FTP目录信息
ftp_info="ftp://192.168.100.81/pub/"

### 临时目录，用于scp存放配置脚本
tmp_path=/root/tools/t_sh/

### 存储节点上OSD盘挂载目录 所有节点统一成一个
osd_path=/osd

### ceph部署的普通用户
deploy_user=gugong
### ceph安装版本
ceph_release=jewel-10.2.3


 ########################################################################
 ########                    设置节点间ssh                   ############
 ########################################################################
 
 ###******* sh/set_selinux_firewall_sudoer.sh **********####

#!/bin/sh
### disable firewall
systemctl disable firewalld.service
systemctl stop firewalld.service
### disable selinux
sed -i -e "s#SELINUX=enforcing#SELINUX=disabled#g" /etc/selinux/config
sed -i -e "s#SELINUXTYPE=targeted#\#SELINUXTYPE=targeted#g" /etc/selinux/config
###set ceph ssh
sed -i -e 's#Defaults   *requiretty#Defaults:ceph !requiretty#g' /etc/sudoers
  

 ###******* set-ssh-openstack-storage-nodes.sh **********####
 
#!/bin/sh
nodes_name=(${!hypervisor_map[@]});

base_location=./wheel_ceph/

sh_name=set_selinux_firewall_sudoer.sh
source_sh=$(echo `pwd`)/sh/$sh_name
target_sh=/root/tools/t_sh/

yum install --nogpgcheck -y epel-release
sudo rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
rm -rf /etc/yum.repos.d/epel*
yum install -y python-pip
yum install -y python-wheel
pip install --use-wheel --no-index --trusted-host $(echo $ftp_info|awk -F "/" '{print $3}') --find-links=$base_location ceph-deploy
ceph-deploy --version

### set
for ((i=0; i<${#hypervisor_map[@]}; i+=1));
  do
      name=${nodes_name[$i]};
      ip=${hypervisor_map[$name]};
      echo "-------------$name------------"
        ssh root@$ip  echo "$deploy_user ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$deploy_user
        ssh root@$ip mkdir -p $target_sh
        scp $source_sh root@$ip:$target_sh
        ssh root@$ip chmod -R +x $target_sh
        ssh root@$ip $target_sh/$sh_name
  done;

[gugong@compute01 2.0_ceph-deploy-tools]$ ^C
[gugong@compute01 2.0_ceph-deploy-tools]$ cat set-ssh-openstack-storage-nodes.sh
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

 ########################################################################
 ########   装前准备 ceph-deploy/防火墙/部署用户sudo/ssh     ############
 ########################################################################
 ###******* sh/set_selinux_firewall_sudoer.sh  **********####
 #!/bin/sh
deploy_user=$1
password_deploy_user=$2
### add ceph-deploy user
echo $password_deploy_user
useradd -d /home/$deploy_user -p $password_deploy_user $deploy_user
(echo $password_deploy_user
sleep 1
echo $password_deploy_user)|passwd $deploy_user

chmod 755 /etc/sudoers.d
echo "$deploy_user ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/$deploy_user
su - $deploy_user <<HERE
sudo chmod 0440 /etc/sudoers.d/$deploy_user
sudo ls -l  /etc/sudoers.d/$deploy_user
HERE
### disable firewall
systemctl disable firewalld.service
systemctl stop firewalld.service
### disable selinux
sed -i -e "s#SELINUX=enforcing#SELINUX=disabled#g" /etc/selinux/config
sed -i -e "s#SELINUXTYPE=targeted#\#SELINUXTYPE=targeted#g" /etc/selinux/config
###set ceph ssh
sed -i -e 's#Defaults   *requiretty#Defaults:ceph !requiretty#g' /etc/sudoers

 
 ###******* install-prerequisites-ceph-deploy.sh  **********####

#!/bin/sh
nodes_name=(${!hypervisor_map[@]});

base_location=./wheel_ceph/

sh_name=set_selinux_firewall_sudoer.sh
source_sh=$(echo `pwd`)/sh/$sh_name
target_sh=/root/tools/t_sh/

yum install --nogpgcheck -y epel-release
sudo rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7
rm -rf /etc/yum.repos.d/epel*
yum install -y python-pip
yum install -y python-wheel
pip install --use-wheel --no-index --trusted-host $(echo $ftp_info|awk -F "/" '{print $3}') --find-links=$base_location ceph-deploy
ceph-deploy --version

### set
for ((i=0; i<${#hypervisor_map[@]}; i+=1));
  do
      name=${nodes_name[$i]};
      ip=${hypervisor_map[$name]};
      echo "-------------$name------------"
        ssh root@$ip mkdir -p $target_sh
        scp $source_sh root@$ip:$target_sh
        ssh root@$ip chmod -R +x $target_sh
        ssh root@$ip $target_sh/$sh_name  $deploy_user $password_deploy_user
  done;
### add deploy-user SSH
su - $deploy_user -c /usr/bin/ssh-keygen
for ((i=0; i<${#hypervisor_map[@]}; i+=1));
  do
      name=${nodes_name[$i]};
      ip=${hypervisor_map[$name]};
      echo "-------------$name------------"
      ssh-copy-id -i /home/$deploy_user/.ssh/id_rsa.pub $deploy_user@$ip
      ssh-copy-id -i /home/$deploy_user/.ssh/id_rsa.pub $deploy_user@$(echo $data_network|cut -d "." -f1-3).$(echo $ip|awk -F "." '{print $4}')
      ssh-copy-id -i /home/$deploy_user/.ssh/id_rsa.pub $deploy_user@$(echo $store_network|cut -d "." -f1-3).$(echo $ip|awk -F "." '{print $4}')
  done;
 ########################################################################
 ########   装前准备 ceph-deploy/防火墙/部署用户sudo/ssh     ############
 ########################################################################
 ###******* replace_ntp_hosts.sh  **********####
  #!/bin/sh
ref_host=$1
sed -i -e 's#server 0.centos.pool.ntp.org#server '"$ref_host"'#g'  /etc/chrony.conf
sed -i -e '/server [0 1 2 3].centos.pool.ntp.org/d'  /etc/chrony.conf
 
 ###******* set-chrony.sh  **********####
 
 #!/bin/sh
subnet=$local_network

ref_host=compute01

sh_name=replace_ntp_hosts.sh
source_sh=./sh/$sh_name
target_sh=$tmp_path

nodes_name=(${!hypervisor_map[@]});

rm -rf result.log

for ((i=0; i<${#hypervisor_map[@]}; i+=1));
  do
      name=${nodes_name[$i]};
      ip=${hypervisor_map[$name]};
      echo "-------------$name------------"
      if [ $name = $ref_host  ]; then
          echo ""$ip
          echo "allow "$subnet >>/etc/chrony.conf
      else
          ssh root@$ip mkdir -p $target_sh
          scp $source_sh root@$ip:$target_sh
          ssh root@$ip chmod +x $target_sh
          ssh root@$ip $target_sh/$sh_name $ref_host
      fi
      ssh root@$ip systemctl enable chronyd.service
      ssh root@$ip systemctl restart chronyd.service
      ssh root@$ip cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
      ssh root@$ip date +%z >>result.log
      ssh root@$ip chronyc sources>>result.log
  done;
  
 ########################################################################
 ########                安装 ceph storage cluster           ############
 ########################################################################

###******* install-configure-ceph-storage-cluster.sh  **********####

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
