#!/bin/bash
# ONOS-SONA docker container deployer BASH profile conveniences
# Simply include in your own .bash_aliases or .bash_profile

# Root of the ONOS DOCKER TOOL source tree
export ONOS_DOCKER=${ONOS_DOCKER:-~/onos-docker-tool}

export DOCKER_KARAF_VERSION=${DOCKER_KARAF_VERSION:-3.0.8}
export DOCKER_KARAF_ROOT=${DOCKER_KARAF_ROOT:-/root/onos/apache-karaf-$DOCKER_KARAF_VERSION}
export DOCKER_KARAF_LOG=$DOCKER_KARAF_ROOT/data/log/karaf.log

# Setup a path
export PATH="$PATH:$ONOS_DOCKER/bin"

# Short-hand for ONOS DOCKER CMD
alias od='onos-docker'
alias odl='onos-docker-log'

export OC1=192.168.56.101
#export OC2=192.168.56.102
#export OC3=192.168.56.103

# If you need to use private IP address to form an ONOS cluster,
# please configure OC_IPS using private IP addresses.
# If OC_IPS is not configured, OC1 ... OCN will be used instead.
#export OC_IPS="192.168.56.101 192.168.56.102 192.168.56.103"
