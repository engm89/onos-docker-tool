#!/bin/bash
# -----------------------------------------------------------------------------
# ARP mode change script.
# -----------------------------------------------------------------------------

function _usage () {
cat << _EOF_
usage: $(basename "$0") [ARP_MODE]

ARP_MODE:
  [broadcast | proxy]

ARP mode change script.

The shell script will refer to environment variables defined in bash_profile to
provision ONOS containers.

_EOF_
}

[ "$1" = "-h" ] || [ "$1" = '-?' ] && _usage && exit 0

# shellcheck disable=SC1091
source envSetup

curl --user onos:rocks -X GET http://$ODC1:8181/onos/openstacknetworking/management/config/arpmode/$1
