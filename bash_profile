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
    if [ ! -f $ONOS_DOCKER_SITE_ROOT/$ONOS_DOCKER_SITE/$ONOS_DOCKER_CELL_FILE ]
    then
      echo "Site $ONOS_DOCKER_SITE does not exist. Use default instead..."
      export ONOS_DOCKER_SITE=default
    fi
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

  echo "Site Name: $ONOS_DOCKER_SITE"

  STALE_ENV_VAR_1=$(env | sort | awk -F "=" '{print $1}' | grep "^ODC[0-9]$")
  STALE_ENV_VAR_2=$(env | sort | awk -F "=" '{print $1}' | grep "^OPC[0-9]$")

  # shellcheck disable=SC2206
  STALE_ACCESS_IPS=($STALE_ENV_VAR_1)
  STALE_PRIVATE_IPS=($STALE_ENV_VAR_2)

  for ((i=0; i < ${#STALE_ACCESS_IPS[@]}; i++))
  {
      odc_name=${STALE_ACCESS_IPS[$i]}
      unset "$odc_name"
  }

  for ((i=0; i < ${#STALE_PRIVATE_IPS[@]}; i++))
  {
      opc_name=${STALE_PRIVATE_IPS[$i]}
      unset "$opc_name"
  }

  source $ONOS_DOCKER_SITE_ROOT/$ONOS_DOCKER_SITE/$ONOS_DOCKER_CELL_FILE

  ENV_VAR_1=$(env | sort | awk -F "=" '{print $1}' | grep "^ODC[0-9]$")
  ENV_VAR_2=$(env | sort | awk -F "=" '{print $1}' | grep "^OPC[0-9]$")

  # shellcheck disable=SC2206
  ACCESS_IPS=($ENV_VAR_1)
  PRIVATE_IPS=($ENV_VAR_2)

  echo "== Cell variables =="
  for ((i=0; i < ${#ACCESS_IPS[@]}; i++))
  {
      oc_name=${ACCESS_IPS[$i]}
      echo "$oc_name = ${!oc_name}"
  }

  for ((i=0; i < ${#PRIVATE_IPS[@]}; i++))
  {
      op_name=${PRIVATE_IPS[$i]}
      echo "$op_name = ${!op_name}"
  }

  KEYSTORE_FILE=keystore.jks
    if [ -f $ONOS_DOCKER_SITE_ROOT/$ONOS_DOCKER_SITE/$KEYSTORE_FILE ]
    then
      KEYSTORE_FILE_PATH=$ONOS_DOCKER_SITE_ROOT/$ONOS_DOCKER_SITE/$KEYSTORE_FILE
      echo "== Path of keystore file =="
      echo ${KEYSTORE_FILE_PATH}
    else
      echo "No keystore.jks file found. HTTPS service will not be available..."
    fi

  COMPONENT_CONFIG_FILE=component-cfg.json
  if [ -f $ONOS_DOCKER_SITE_ROOT/$ONOS_DOCKER_SITE/$COMPONENT_CONFIG_FILE ]
  then
    echo "== component-cfg.json =="
    cat $ONOS_DOCKER_SITE_ROOT/$ONOS_DOCKER_SITE/$COMPONENT_CONFIG_FILE
  else
    echo "No component-cfg.json file. Will use default config variables..."
  fi

  NETWORK_CONFIG_FILE=network-cfg.json
  if [ -f $ONOS_DOCKER_SITE_ROOT/$ONOS_DOCKER_SITE/$NETWORK_CONFIG_FILE ]
  then
    echo "== network-cfg.json =="
    cat $ONOS_DOCKER_SITE_ROOT/$ONOS_DOCKER_SITE/$NETWORK_CONFIG_FILE
  else
    echo "No network-cfg.json file. Will use default config variables..."
  fi
}
