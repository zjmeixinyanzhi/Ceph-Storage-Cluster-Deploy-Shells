# Ceph存储集群安装部署脚本
## 说明：
* CentOS 7.2部署Ceph
* root用户执行ceph-deploy安装ceph集群

## 使用步骤

1、修改安装配置文件
默认：OSD盘指定为/dev裸磁盘设备而并非目录，无需挂载(/dev/sdb) 在配置文件中osd_path指定即可
```shell
vim 0-set-config.sh
. 0-set-config.sh
```
2、SSH
计算节点间Root的无密码访问
```shell
. set-ssh-openstack-storage-nodes.sh
```
3、selinux 防火墙 安装ceph-deploy 创建指定的普通部署用户，增加sudo权限，并开启该用户跨计算节点的ssh
```shell
. install-prerequisites-ceph-deploy.sh
```
4、时间同步：默认其他节点时间与compute01同步
```shell
. set-chrony.sh
```
5、安装部署，利用普通用户执行ceph-deploy
```shell
. install-configure-ceph-storage-cluster.sh
```



