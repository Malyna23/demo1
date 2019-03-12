#!/usr/bin/bash

sudo yum -y update

#Install Load Balancer
sudo yum -y install haproxy
sudo systemctl enable haproxy
sudo systemctl start haproxy

#Haproxy configuration
sudo rm /etc/haproxy/haproxy.cfg
sudo cat <<EOF | sudo tee -a /etc/haproxy/haproxy.cfg

global
    
    log         127.0.0.1 local2

    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon

    # turn on stats unix socket
    stats socket /var/lib/haproxy/stats


defaults
    mode                    http
    log                     global
    option                  httplog
    option                  dontlognull
    option http-server-close
    option forwardfor       except 127.0.0.0/8
    option                  redispatch
    retries                 3
    timeout http-request    10s
    timeout queue           1m
    timeout connect         10s
    timeout client          1m
    timeout server          1m
    timeout http-keep-alive 10s
    timeout check           10s
    maxconn                 3000

listen stats *:8080
 mode http
 stats enable
 stats realm LoadBalancer_statistics
 stats scope app
 stats scope https-web
 stats scope http-app
 stats scope mysql-proxy
 stats auth admin:adminpassword
 stats uri /stats



frontend  main 192.168.56.2:80
    acl url_static       path_beg       -i /static /images /javascript /stylesheets
    acl url_static       path_end       -i .jpg .gif .png .css .js

    use_backend static          if url_static
    default_backend             app

backend static
    balance     roundrobin
    server      static 127.0.0.1:4331 check

backend app
    balance     roundrobin
    server  app1 192.168.56.3:80 check
    server  app2 192.168.56.6:80 check
EOF
sudo systemctl restart haproxy

#Firewall configuration
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --permanent --zone=public --add-service=http 
sudo firewall-cmd --permanent --zone=public --add-rich-rule='
  rule family="ipv4"
  source address="192.168.56.0/24"
  port protocol="tcp" port="8080" accept'
sudo firewall-cmd --reload