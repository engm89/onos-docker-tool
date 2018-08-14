#!/bin/bash
# -----------------------------------------------------------------------------
# ONOS container removal shell script.
# -----------------------------------------------------------------------------

function _usage () {
cat << _EOF_
usage: $(basename "$0")

ONOS container removal shell script.

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

# stop & remove ONOS-SONA container
echo "Removing ONOS-SONA docker image..."

for ((i=0; i < ${#ACCESS_IPS[@]}; i++))
{
    oc_name=${ACCESS_IPS[$i]}

    # shellcheck disable=SC2086
    if [ "$(ssh sdn@${!oc_name} 'sudo docker ps -q -a -f name=onos')" ]; then
        echo "Wiping out the ONOS-SONA container at ${!oc_name}..."
        ssh sdn@"${!oc_name}" "sudo docker stop onos || true" > /dev/null
        ssh sdn@"${!oc_name}" "sudo docker rm onos || true" > /dev/null
    fi

    # shellcheck disable=SC2086
    if [ "$(ssh sdn@${!oc_name} 'sudo docker ps -q -a -f name=atomix')" ]; then
        echo "Wiping out the ATOMIX container at ${!oc_name}..."
        ssh sdn@"${!oc_name}" "sudo docker stop atomix || true" > /dev/null
        ssh sdn@"${!oc_name}" "sudo docker rm atomix || true" > /dev/null
    fi
}

# remove ONOS configuration directory
echo "Removing ONOS and ATOMIX configuration directory..."

for ((i=0; i < ${#ACCESS_IPS[@]}; i++))
{
    oc_name=${ACCESS_IPS[$i]}
    echo "Removing ATOMIX configuration at ${!oc_name}..."
    ssh sdn@"${!oc_name}" "rm -rf ~/atomix_config"
    echo "Removing ONOS configuration at ${!oc_name}..."
    ssh sdn@"${!oc_name}" "rm -rf ~/onos_config"
}
