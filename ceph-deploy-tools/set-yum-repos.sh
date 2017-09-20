#!/bin/sh
#
# Generate ceph repo

yum install -y yum-utils && sudo yum-config-manager --add-repo https://dl.fedoraproject.org/pub/epel/7/x86_64/ && sudo yum install --nogpgcheck -y epel-release && sudo rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7 && sudo rm /etc/yum.repos.d/dl.fedoraproject.org*

pssh -i -h ./hosts/nodes.txt "rpmdb --rebuilddb"
pssh -i -h ./hosts/nodes.txt "yum repolist all"
pssh -i -h ./hosts/nodes.txt "yum upgrade -y"
