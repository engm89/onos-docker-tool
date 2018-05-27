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
alias ods='onos-docker-site'

# Setup docker-site enviroment
export ONOS_DOCKER_SITE_ROOT=$ONOS_DOCKER/site
export ONOS_DOCKER_SITE=${ONOS_DOCKER_SITE:-default}
export ONOS_DOCKER_CELL_FILE=cell

source $ONOS_DOCKER_SITE_ROOT/$ONOS_DOCKER_SITE/$ONOS_DOCKER_CELL_FILE

function onos-docker-site {
  if [ -z $1 ]
  then
    export ONOS_DOCKER_SITE=${ONOS_DOCKER_SITE:-default}
  else
    if [ -f $ONOS_DOCKER_SITE_ROOT/$1/$ONOS_DOCKER_CELL_FILE ]
    then
      export ONOS_DOCKER_SITE=$1
    else
      echo "Please specify a valid site! Site should be located under site directory."
      echo "The default site profile will be used instead."
      export ONOS_DOCKER_SITE=default
    fi
  fi

  source $ONOS_DOCKER_SITE_ROOT/$ONOS_DOCKER_SITE/$ONOS_DOCKER_CELL_FILE

  echo "Site Name: $ONOS_DOCKER_SITE"

  ENV_VAR=$(env | sort | awk -F "=" '{print $1}' | grep "^ODC[0-9]$")
  # shellcheck disable=SC2206
  ACCESS_IPS=($ENV_VAR)

  echo "Following cell variables will be used..."
  for ((i=0; i < ${#ACCESS_IPS[@]}; i++))
  {
      oc_name=${ACCESS_IPS[$i]}
      echo "$oc_name = ${!oc_name}"
  }

  COMPONENT_CONFIG_FILE=component-cfg.json
  if [ -f $ONOS_DOCKER_SITE_ROOT/$ONOS_DOCKER_SITE/$COMPONENT_CONFIG_FILE ]
  then
    cat $ONOS_DOCKER_SITE_ROOT/$ONOS_DOCKER_SITE/$COMPONENT_CONFIG_FILE
  else
    echo "No component-cfg.json file. Will use default config variables..."
  fi
}
