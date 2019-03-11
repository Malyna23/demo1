#!/usr/bin/bash

sudo yum -y update 

#Install web-server(Apache2)
sudo yum -y install httpd 
sudo systemctl start httpd.service      
sudo systemctl enable httpd.service

#Install php7.2
sudo yum -y install epel-release
sudo yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm
sudo yum-config-manager --enable remi-php72
sudo yum -y update
sudo yum -y install php php-mysql php-xml php-xmlrpc php-gd php-intl php-mbstring php-soap php-zip php-opcache php-cli php-pgsql php-pdo php-fileinfo php-curl php-common php-fpm php-redis
sudo systemctl restart httpd.service
sudo sed -i -e "s/session.save_handler = files/session.save_handler = redis/g" /etc/php.ini

#Install moodle 3.6
sudo yum -y install wget
sudo wget https://download.moodle.org/download.php/direct/stable36/moodle-latest-36.tgz
sudo rm -rf /var/www/html/
sudo tar -zxvf moodle-latest-36.tgz -C /var/www/
sudo mv /var/www/moodle /var/www/html
sudo setsebool httpd_can_network_connect true
sudo /usr/bin/php /var/www/html/admin/cli/install.php --wwwroot=http://192.168.56.2/ --dataroot=/var/moodledata --dbtype=pgsql --dbhost=192.168.56.4 --dbport=5432 --dbname=dbname --dbuser=dbname --dbpass=dbname --fullname="Moodle" --adminpass=1Qaz2wsx$  --shortname="Moodle" --non-interactive --agree-license
sudo chmod a+r /var/www/html/config.php
sudo chcon -R -t httpd_sys_rw_content_t /var/moodledata
sudo rm /var/www/html/config.php
sudo cat <<EOF | sudo tee -a /var/www/html/config.php
<?php  // Moodle configuration file

unset(\$CFG);
global \$CFG;
\$CFG = new stdClass();

\$CFG->dbtype    = 'pgsql';
\$CFG->dblibrary = 'native';
\$CFG->dbhost    = '192.168.56.4';
\$CFG->dbname    = 'dbname';
\$CFG->dbuser    = 'dbname';
\$CFG->dbpass    = 'dbname';
\$CFG->prefix    = 'mdl_';
\$CFG->dboptions = array (
  'dbpersist' => 0,
  'dbport' => 5432,
  'dbsocket' => '',
);

\$CFG->wwwroot   = 'http://192.168.56.2';
\$CFG->dataroot  = '/var/moodledata';
\$CFG->admin     = 'admin';
\$CFG->session_handler_class = '\core\session\redis';
\$CFG->session_redis_host = '192.168.56.7';
\$CFG->session_redis_port = 6379;  // Optional.
\$CFG->session_redis_database = 0;  // Optional, default is db 0.
\$CFG->session_redis_prefix = ''; // Optional, default is don't set one.
\$CFG->session_redis_acquire_lock_timeout = 120;
\$CFG->session_redis_lock_expire = 7200;

\$CFG->directorypermissions = 02777;

require_once(__DIR__ . '/lib/setup.php');

EOF
sudo systemctl start firewalld.service
sudo firewall-cmd --permanent --zone=public --add-rich-rule='
  rule family="ipv4"
  source address="192.168.56.0/24"
  port protocol="tcp" port="80" accept'
sudo firewall-cmd --reload


