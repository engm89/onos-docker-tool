#!/bin/bash
# -----------------------------------------------------------------------------
# SONA VM connection test with given floating IPs.
# -----------------------------------------------------------------------------

function _usage () {
cat << _EOF_
usage: $(basename "$0")

SONA VM connection test shell script.

The shell script will refer to environment variables defined in bash_profile to
test the connctivity to VMs which assigned floating IPs.

_EOF_
}

[ "$1" = "-h" ] || [ "$1" = '-?' ] && _usage && exit 0

# shellcheck disable=SC1091
source envSetup

ipList=`curl -s --user onos:rocks -X GET http://$ODC1:8181/onos/openstacknetworking/management/floatingips/mapped`
python asset/ping-test $ipList
