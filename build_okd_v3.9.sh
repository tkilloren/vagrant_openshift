#!/bin/sh

vagrant up

ansible-playbook ansible/01_setup_vbox_machines.pb.yml
ansible-playbook ansible/02_prerequisites.pb.yml
ansible-playbook ansible/03_deploy_cluster.pb.yml
