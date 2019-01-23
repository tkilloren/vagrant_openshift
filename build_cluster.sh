#!/bin/sh
#=============================================================
# build_cluster.sh
#
# This shell script orchestrates building OpenShift on
# VirtualBox.
#=============================================================
#FIXME - Add as commandline parameters
OPENSHIFT_RELEASE_MAJOR='3'
OPENSHIFT_RELEASE_MINOR='6'
OPENSHIFT_DEPLOYMENT_TYPE="origin"
#OPENSHIFT_DEPLOYMENT_TYPE="openshift-enterprise"


#
# Some shortcuts for the various versioning formats
#
release_dot="${OPENSHIFT_RELEASE_MAJOR}.${OPENSHIFT_RELEASE_MINOR}"
release_short="${OPENSHIFT_RELEASE_MAJOR}${OPENSHIFT_RELEASE_MINOR}"


#
#Point to proper version of ansible hosts file
#FIXME - Once more versions work find generalization about hosts
#
echo "* Changing inventory/hosts symlink to ${release_dot}"

cd inventory
rm hosts
ln -s ".hosts.${release_dot}" hosts
cd ..

echo


#------------------------------------
# 1) Build the virtual hardware with Vagrant
#------------------------------------
echo "* Run Vagrant for ${OPENSHIFT_DEPLOYMENT_TYPE} deployment"

OPENSHIFT_RELEASE="${release_dot}" \
OPENSHIFT_DEPLOYMENT_TYPE="${OPENSHIFT_DEPLOYMENT_TYPE}" \
vagrant up

echo


#------------------------------------
# 2) Prepare the VMs for the install
#   * Add required RPM repositories
#   * Set up /etc/hosts since we don't have DNS
#------------------------------------
echo "* Prepare VMs for OpenShift ${release_dot} deployer"

ansible-playbook ansible/01_setup_vbox_machines.pb.yml \
  -e "okd_repo_rpm=centos-release-openshift-origin${release_short}"

echo


#------------------------------------
# 3) Run the OpenShift Advanced Deployment
#------------------------------------

#FIXME: Add method for unpacking offical rpm based installer
install_root='installers/github'

# If using GitHub openshift-ansible, change branch to proper version
if [ "${install_root}" = 'installers/github' ]; then
  echo "* Checkout release-${release_dot} branch"

  cd installers/github/openshift-ansible
  git checkout release-${release_dot}
  cd ../../..

  echo
fi

# Pick the proper play naming layout based on version
if [ "$OPENSHIFT_RELEASE_MINOR" -le 7 ]; then
  plays="${install_root}/openshift-ansible/playbooks/byo/config.yml"
else
  plays="${install_root}/openshift-ansible/playbooks/prerequisites.yml
  ${install_root}/openshift-ansible/playbooks/deploy_cluster.yml"
fi

# Run the advanced deployment playbook
echo "* Run advanced deployment for OpenShift ${release_dot}"
for play in ${plays}; do
  ansible-playbook -vvv "${play}"
done
