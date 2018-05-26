#!/bin/bash
# ONOS-SONA docker container deployer BASH profile conveniences
# Simply include in your own .bash_aliases or .bash_profile

unset ONOS_DOCKER
if [ -z ${ONOS_DOCKER} ]; then
  ONOS_DOCKER="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
fi

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
alias odc='onos-docker-cell'

# Setup docker-cell enviroment
export ONOS_DOCKER_CELL_DIR=$ONOS_DOCKER/cell
export ONOS_DOCKER_CELL=${ONOS_DOCKER_CELL:-default}

source $ONOS_DOCKER_CELL_DIR/$ONOS_DOCKER_CELL

function onos-docker-cell {
  unset ONOS_DOCKER_CELL
  if [ -f $ONOS_DOCKER/cell/$1 ]
  then
    export ONOS_DOCKER_CELL=$1
  else
    echo "Please specify a valid cell! Cell file should be located under cell DIR."
    echo "default cell will be used..."
    export ONOS_DOCKER_CELL=default
  fi

  source $ONOS_DOCKER/cell/$ONOS_DOCKER_CELL

  ENV_VAR=$(env | sort | awk -F "=" '{print $1}' | grep "^ODC[0-9]$")
  # shellcheck disable=SC2206
  ACCESS_IPS=($ENV_VAR)

  echo "Following ENV variable will be used for cell $1"
  for ((i=0; i < ${#ACCESS_IPS[@]}; i++))
  {
      oc_name=${ACCESS_IPS[$i]}
      echo "$oc_name = ${!oc_name}"
  }
}
