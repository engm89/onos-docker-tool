#!/bin/bash
# -----------------------------------------------------------------------------
# SONA state and rules synchronization shell script.
# -----------------------------------------------------------------------------

function _usage () {
cat << _EOF_
usage: $(basename "$0")

SONA sync-states and sync-rules shell script.

The shell script will refer to environment variables defined in bash_profile to
synchronize SONA with OpenStack neutron store.

_EOF_
}

[ "$1" = "-h" ] || [ "$1" = '-?' ] && _usage && exit 0

# shellcheck disable=SC1091
source envSetup

curl --user onos:rocks -X GET http://$ODC1:8181/onos/openstacknetworking/management/sync/states
curl --user onos:rocks -X GET http://$ODC1:8181/onos/openstacknetworking/management/sync/rules
curl --user onos:rocks -X GET http://$ODC1:8181/onos/openstacknetworking/management/sync/rules
