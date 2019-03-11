#!/bin/bash

sudo yum -y update

#Install DB (PostgreSQL)
sudo yum -y install https://download.postgresql.org/pub/repos/yum/11/redhat/rhel-7-x86_64/pgdg-redhat11-11-2.noarch.rpm
sudo yum -y install postgresql11-server
sudo /usr/pgsql-11/bin/postgresql-11-setup initdb
sudo systemctl start postgresql-11
sudo systemctl enable postgresql-11

#Database configuration
sudo -u postgres psql -c "CREATE USER dbname WITH ENCRYPTED PASSWORD 'dbname';"
sudo -u postgres psql -c "CREATE DATABASE dbname WITH OWNER dbname;"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE dbname to dbname;"

sudo sed -i -e "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /var/lib/pgsql/11/data/postgresql.conf
sudo sed -i -e "s/#port = 5432/port = 5432/g" /var/lib/pgsql/11/data/postgresql.conf
sudo cat <<EOF | sudo tee -a /var/lib/pgsql/11/data/pg_hba.conf
host    all             all              0.0.0.0/0        password
EOF

sudo systemctl restart postgresql-11
#Firewall configuration
sudo systemctl start firewalld.service
sudo firewall-cmd --permanent --zone=public --add-rich-rule='
   rule family="ipv4"
   source address="192.168.56.0/24"
   port protocol="tcp" port="5432" accept'
sudo firewall-cmd --reload

