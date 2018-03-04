require 'ipaddr'

number_of_nodes = 5
first_node_ip = '10.10.0.201'
node_ip_addr = IPAddr.new first_node_ip

Vagrant.configure(2) do |config|
  #config.vm.box = 'ubuntu-16.04-amd64'
  config.vm.box = 'ubuntu-bionic'

  config.vm.synced_folder ".", "/vagrant", type: :nfs, :mount_options => ['nolock,vers=3,udp,noatime']

  config.vm.provider "vmware_workstation" do |vmware|
    vmware.gui = false
    vmware.vmx["memsize"] = 2048
    vmware.vmx["numvcpus"] = 4
  end

  config.vm.provider 'virtualbox' do |vb|
    vb.linked_clone = true
    vb.memory = 2*1024
    vb.cpus = 4
  end

  (1..number_of_nodes).each do |n|
    name = "docker#{n}"
    fqdn = "#{name}.example.com"
    ip = node_ip_addr.to_s; node_ip_addr = node_ip_addr.succ

    config.vm.define name do |config|
      config.vm.hostname = fqdn
      config.vm.network :private_network, ip: ip
      config.vm.provision 'shell', path: 'provision-apt-proxy.sh'
      config.vm.provision 'shell', path: 'provision-base.sh'
      config.vm.provision 'shell', path: 'provision-certification-authority.sh'
      config.vm.provision 'shell', path: 'provision-hosts.sh', args: [ip]
      config.vm.provision 'shell', path: 'provision-docker.sh'
      config.vm.provision 'shell', path: 'provision-docker-swarm.sh', args: [ip, first_node_ip, n]
      config.vm.provision 'shell', path: 'provision-registry.sh' if ip == first_node_ip
      config.vm.provision 'shell', path: 'provision-portainer.sh' if ip == first_node_ip
      config.vm.provision 'shell', path: 'provision-examples.sh' if ip == first_node_ip
    end
  end
end
