# -*- mode: ruby -*-
# vi: set ft=ruby :
VAGRANTFILE_API_VERSION = "2"

## FIXME: logic to set to "generic/rhel7" when doing enterprise install
VAGRANTBOX = "generic/centos7"
OPENSHIFT_RELEASE = "3.9"

#=========================
# Define Virtual Machines
#  Memory is in megabytes
#=========================

## FIXME: Add logic for port forwarding
virtual_machines = [
  { :name => "master-1",
    :cpus => "1",
    :memory => "2048",
    :private_ip => "192.168.33.71" },
  { :name => "app-1",
    :cpus => "1",
    :memory => "2048",
    :private_ip => "192.168.33.72" },
  { :name => "infra-1",
    :cpus => "1",
    :memory => "4048",
    :private_ip => "192.168.33.73" }
]

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = VAGRANTBOX

  # Setup some defaults
  config.vm.provider :virtualbox do |default|
    default.memory = 1024
    default.cpus = 1
    # Use Linked Clones to Speed up Provisioning
    # https://www.vagrantup.com/docs/virtualbox/configuration.html#linked-clones
    default.linked_clone = true
  end

  # Provision each of the VMs
  virtual_machines.each do |opts|
    config.vm.define opts[:name] do |node|
      node.vm.hostname = opts[:name]
      node.vm.network :private_network, ip: opts[:private_ip]

      node.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--cpus", opts[:cpus]]
        vb.customize ["modifyvm", :id, "--ioapic", "on"]
        vb.customize ["modifyvm", :id, "--memory", opts[:memory]]
        # Use more verbose name for displaying in VirtualBox
        vb.customize ["modifyvm", :id, "--name", "OCP #{OPENSHIFT_RELEASE} #{opts[:name]}"]
      end

    end
  end
end
