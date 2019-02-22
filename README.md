Vagrant OpenShift Deploy
========================

A pattern for installing OpenShift onto VirtualBox using Vagrant and Ansible.

Intro
-----

I needed a way to use my workstation to test the ansible deployer for OpenShift and didn't find any great solutions.
Minishift and minikube are easy ways to spin up a simple cluster but are already doing the deployment for you.  They also have limited options about what the configured platform looks like (e.g. testing the logging stack).  Great to use if you are a consumer of the platform but not perfect if you are a maintainer of the platform.


Prereqs
-------

Sorry, only Mac instructions for now (although Linux should only be a small leap).

You will need the following installed on your Mac.
* [VirtualBox](https://www.virtualbox.org)
* [Vagrant](https://www.vagrantup.com)
* [Homebrew](https://brew.sh)


Setup Tools
-----------

### Clone this repo

```shell
git clone https://github.com/tkilloren/vagrant_openshift.git
cd vagrant_openshift
```

### Install Ansible on the WorkStation

```shell
brew install ansible
```

### Add requirements for vagrant dynamic inventory script

Run one time:
```shell
pip install virtualenv
virtualenv --python=/usr/bin/python venv
. venv/bin/activate
pip install -r requirements.txt
```

You will need to run the following when opening a new shell for running ansible:
```shell
. venv/bin/activate
```

### Clone the OpenShift ansible installer from github

```shell
mkdir -p installers/github
cd installers/github
git clone https://github.com/openshift/openshift-ansible.git
cd openshift-ansible
git fetch origin --all
cd ../../..
```


Run the Cluster Install
-----------------------

### Build the cluster

```shell
./build_cluster.sh
```

Using Cluster
------------

### Listing VMs
```shell
vagrant status
```


### Logging on to a VM and become root

```shell
vagrant ssh master-1
sudo -i
```

### Connecting to web console

Use browser to connect to https://ocp.192.168.33.11.nip.io:8443

The default username:password is <code>system:admin</code>

### Running OC client against cluster

Download the cli tool:
```shell
brew install openshift-cli
```

### Connect to OpenShift router

Use browser to connect to https://apps.192.168.33.21.nip.io

example:

https://myapp.apps.192.168.33.21.nip.io


Clean up
--------

This command will destroy all the virtual machines.
```shell
vagrant destroy -f
```
