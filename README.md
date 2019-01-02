Vagrant OpenShift Deploy
========================

A pattern for installing OpenShift onto VirtualBox using Vagrant and Ansible.

Intro
-----

I needed a way to use my workstation to test the ansible deployer for OpenShift and didn't find any great solutions.
Minishift and minikube are easy ways to spin up a simple cluster but are already doing the deployment for you.  They also have limited options about what the configured platform looks like (e.g. testing the logging stack).  Great to use if you are a consumer of the platform but not perfect if you are a maintainer of the platform.


Prereqs
-------

Sorry, only Mac instructions for now.

You will need the following installed on your Mac.
* VirtualBox
* Vagrant
* Homebrew


Setup Tools
-----------

### Clone this repo

```shell
git clone https://github.com/tkilloren/vagrant_openshift.git
```

### Install Ansible on the WorkStation

```shell
brew install ansible
```

### Add requirements for vagrant dynamic inventory script

Run one time:
```shell
pip install virtualenv
virtualenv venv
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
git fetch origin
git checkout release-3.10
```


Run the Cluster Install
-----------------------

### Build the virtual hardware

```shell
vagrant up
```

### Run the Prerequisite playbook

```shell
ansible-playbook prerequisites.yml
```

### Run the Deploy_Cluster playbook

```shell
ansible-playbook deploy_cluster.yml
```


Using Cluster
------------

### Connecting to a node

```shell
vagrant ssh master-1
sudo -i
```

Clean up
--------

This command will destroy all the virtual machines.
```shell
vagrant destroy -f
```
