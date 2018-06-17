#!/bin/bash
# -----------------------------------------------------------------------------
# ONOS network-cfg.json push shell script.
# -----------------------------------------------------------------------------

function _usage () {
cat << _EOF_
usage: $(basename "$0")

ONOS network-cfg.json push shell script.

The shell script will refer to environment variables defined in bash_profile to
push the network-cfg.json to ONOS containers.

_EOF_
}

[ "$1" = "-h" ] || [ "$1" = '-?' ] && _usage && exit 0

# shellcheck disable=SC1091
source envSetup

NETWORK_CFG_FILE=$ONOS_DOCKER_SITE_ROOT/$ONOS_DOCKER_SITE/network-cfg.json

if [ -f $NETWORK_CFG_FILE ]
then
  echo "PUT network-cfg.json of $ONOS_DOCKER_SITE to $ODC1"
  curl --user onos:rocks -X PUT -H "Content-Type: application/json" http://$ODC1:8181/onos/openstacknode/configure -d @$NETWORK_CFG_FILE
else
  echo "network-cfg.json is NOT found. Please create one first."
fi
