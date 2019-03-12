IPBALANCER=$1
sudo sed -i "/server  app2 192.168.56.6:80 check/a\ server app $IPBALANCER:80 check" /etc/haproxy/haproxy.cfg

#Restart Haproxy
sudo systemctl restart haproxy
