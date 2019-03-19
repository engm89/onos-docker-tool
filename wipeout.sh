#!/bin/bash
# -----------------------------------------------------------------------------
# ONOS containers and images wipe out shell script.
# -----------------------------------------------------------------------------

function _usage () {
cat << _EOF_
usage: $(basename "$0")

ONOS container and image removal shell script.

The shell script will refer to environment variables defined in bash_profile to
provision ONOS containers.

_EOF_
}

[ "$1" = "-h" ] || [ "$1" = '-?' ] && _usage && exit 0

# shellcheck disable=SC1091
source envSetup

if [ ${#ACCESS_IPS[@]} -eq 0 ]; then
    echo "No ONOS Controller IP addresses were configured!"
    echo "Please configure IP address in bash_profile."
    exit 1
fi

# stop & remove ONOS-SONA container and image
echo "Removing ONOS-SONA docker image..."

for ((i=0; i < ${#ACCESS_IPS[@]}; i++))
{
    oc_name=${ACCESS_IPS[$i]}

    echo "Wiping out all containers and images ${!oc_name}..."
    ssh sdn@"${!oc_name}" "sudo docker system prune -a || true" > /dev/null
}
