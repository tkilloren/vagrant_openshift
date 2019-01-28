#!/bin/sh
#=============================================================
# build_cluster.sh
#
# This shell script orchestrates building OpenShift on
# VirtualBox.
#=============================================================

#============
# Functions
#============
usage()
{
  echo "Usage:" >&2
  echo "  $0 [ehv?] [ -m OPENSHIFT_MINOR_VERSION  ]" >&2
  exit 2
}

#============
# Parse CLI
#============

#
# Defaults
#
unset verbose
openshift_release_major='3'
openshift_release_minor='11'
openshift_deployment_type='origin'

#
# Parse
#
while getopts 'vem:?h' opt
do
  case "$opt" in
    v)  verbose=true;;
    m)  openshift_release_minor="$OPTARG";;
    e)  openshift_deployment_type='openshift-enterprise';;
    h|?) usage;;
  esac
done
shift `expr $OPTIND - 1`

# Only valid major is 3 for now
# ansible_flags="${ansible_flags} -e release_major=${openshift_release_major}"
ansible_flags="${ansible_flags} -e release_minor=${openshift_release_minor}"

if [ "${openshift_deployment_type}" = 'openshift-enterprise' ]; then
  ansible_flags="${ansible_flags} -e openshift_deployment_type=openshift-enterprise"
fi

if [ "$verbose" ]; then
  ansible_flags="${ansible_flags} -vvv"
fi

#
# Some shortcuts for the various versioning formats
#
release_dot="${openshift_release_major}.${openshift_release_minor}"
release_short="${openshift_release_major}${openshift_release_minor}"


#============
# Main ()
#============

#------------------------------------
# 0) Setup deploy environment
#------------------------------------
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
echo "* Run Vagrant for ${openshift_deployment_type} deployment"

OPENSHIFT_RELEASE="${release_dot}" \
OPENSHIFT_DEPLOYMENT_TYPE="${openshift_deployment_type}" \
vagrant up

echo


#------------------------------------
# 2) Prepare the VMs for the install
#   * Add required RPM repositories
#   * Set up /etc/hosts since we don't have DNS
#------------------------------------
echo "* Prepare VMs for OpenShift ${release_dot} deployer"

ansible-playbook ansible/01_setup_vbox_machines.pb.yml ${ansible_flags}

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
if [ "$openshift_release_minor" -le 7 ]; then
  plays="${install_root}/openshift-ansible/playbooks/byo/config.yml"
else
  plays="${install_root}/openshift-ansible/playbooks/prerequisites.yml
  ${install_root}/openshift-ansible/playbooks/deploy_cluster.yml"
fi

# Run the advanced deployment playbook
echo "* Run advanced deployment for OpenShift ${release_dot}"
for play in ${plays}; do
  ansible-playbook "${play}" ${ansible_flags}
done
