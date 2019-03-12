Vagrant.configure(2) do |config|
servers=[
  {
    :hostname => "db",
    :ip => "192.168.56.4",
    :box => "centos/7",
    :ram => 1024,
    :cpu => 1,
    :path => "scenario_db.sh"
  },
  {
    :hostname => "redis",
    :ip => "192.168.56.7",
    :box => "centos/7",
    :ram => 1024,
    :cpu => 1,
    :path => "scenario_redis.sh"
  },
  {
    :hostname => "web",
    :ip => "192.168.56.3",
    :box => "centos/7",
    :ram => 1024,
    :cpu => 1,
    :path => "scenario_web.sh"
  },
  {
    :hostname => "web1",
    :ip => "192.168.56.6",
    :box => "centos/7",
    :ram => 1024,
    :cpu => 1,
    :path => "scenario_web.sh"
  }
]


  servers.each do |machine|
      config.vm.define machine[:hostname] do |node|
          node.vm.box = machine[:box]
          node.vm.hostname = machine[:hostname]
          node.vm.network "private_network", ip: machine[:ip]
          node.vm.network "public_network", machine
          node.vm.provider "virtualbox" do |vb|
              vb.customize ["modifyvm", :id, "--memory", machine[:ram]]
          end
          node.vm.provision "shell", path: machine[:path]
      end
  end

  N = 2
  (1..N).each do |machine_id|
    config.vm.define "webserv#{machine_id}" do |machineweb|
      machineweb.vm.box = "centos/7"
      machineweb.vm.hostname = "webserv#{machine_id}"
      machineweb.vm.network "private_network", ip: "192.168.56.#{10+machine_id}"
      machineweb.vm.network "public_network"
      if machine_id == 1
        machineweb.vm.provision "shell", path: "scenario_web.sh"
      else  
        machineweb.vm.provision "shell", path: "scenario_web.sh" 
      end
    end
  end
  config.vm.define "balancer" do |balancer|
    balancer.vm.box = "centos/7"
    balancer.vm.network "private_network", ip: "192.168.56.2"
    balancer.vm.network "public_network"
    balancer.vm.provision "shell", path: "scenario_haproxy.sh"
    (1..N).each do |n|
      IPBALANCER="192.168.56.#{10+n}"
      balancer.vm.provision "shell", path: "scenario_ip.sh", :args => [IPBALANCER]
    end
  end
end