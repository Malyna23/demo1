IPBALANCER=$1
N=$2
sudo sed -i "/server  app2 192.168.56.6:80 check/a\ server app $IPBALANCER:80 check" /etc/haproxy/haproxy.cfg


#Install Haproxy

sudo systemctl restart haproxy