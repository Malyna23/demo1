#!/bin/bash

sudo yum -y update

#Install Redis
sudo yum -y install epel-release yum-utils
sudo yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
sudo yum-config-manager --enable remi
sudo yum -y install redis
sudo systemctl start redis
sudo systemctl enable redis

sudo sed -i -e "s/bind 127.0.0.1/bind 0.0.0.0/g" /etc/redis.conf

sudo systemctl restart redis

#Firewall configuration
sudo systemctl start firewalld.service
sudo firewall-cmd --permanent --zone=public --add-rich-rule='
   rule family="ipv4"
   source address="192.168.56.0/24"
   port protocol="tcp" port="6379" accept'
sudo firewall-cmd --reload