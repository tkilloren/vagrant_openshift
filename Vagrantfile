# -*- mode: ruby -*-
# vi: set ft=ruby :
VAGRANTFILE_API_VERSION = "2"

#=========================
# Parameters
#=========================
openshift_release = ENV["OPENSHIFT_RELEASE"] || "3.11"
openshift_deployment_type = ENV["OPENSHIFT_DEPLOYMENT_TYPE"] || "origin"


#=========================
# Deployment Type Settings
#=========================
case openshift_deployment_type
when "origin"
  deploy_name = "okd"
  vagrantbox = "generic/centos7"
when "openshift-enterprise"
  deploy_name = "osp"
  vagrantbox = "generic/rhel7"
else
  puts 'Unknown value for OPENSHIFT_DEPLOYMENT_TYPE'
  puts 'should be one of the following values:'
  puts 'origin'
  puts 'openshift-enterprise'
  exit 1
end


#=========================
# Define Virtual Machines
#  Memory is in megabytes
#=========================
## FIXME: Add logic for port forwarding
virtual_machines = [
  { :name => "master-1",
    :cpus => "1",
    :memory => "4096",
    :private_ip => "192.168.33.11" },
  { :name => "infra-1",
    :cpus => "1",
    :memory => "4096",
    :private_ip => "192.168.33.21" },
  { :name => "app-1",
    :cpus => "1",
    :memory => "2048",
    :private_ip => "192.168.33.31" }
]

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = vagrantbox

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
        vb.customize ["modifyvm", :id, "--name", "#{deploy_name} #{openshift_release} #{opts[:name]}"]
      end

    end
  end
end
