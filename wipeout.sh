#!/bin/bash
# -----------------------------------------------------------------------------
# ONOS container and image removal shell script.
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

if [ ${#PUBLIC_OC_IPS[@]} -eq 0 ]; then
    echo "No ONOS Controller IP addresses were configured!"
    echo "Please configure IP address in bash_profile."
    exit 1
fi

echo "Following IP addresses will be used to terminate ONOS containers."
for ((i=0; i < ${#PUBLIC_OC_IPS[@]}; i++))
{
    pub_oc_name=${PUBLIC_OC_IPS[$i]}
    echo "$pub_oc_name = ${!pub_oc_name}"
}

if [ ${#PUBLIC_OCC_IPS[@]} -eq 0 ]
then
    PUBLIC_OCC_IPS=(${PUBLIC_OC_IPS[@]})
fi

echo "Following IP address will be used to terminate storage containers."
for ((i=0; i < ${#PUBLIC_OCC_IPS[@]}; i++))
{
    pub_occ_name=${PUBLIC_OCC_IPS[$i]}
    echo "$pub_occ_name = ${!pub_occ_name}"
}

# stop & remove ONOS-SONA container
echo "Removing ONOS-SONA docker container and config directory..."
for ((i=0; i < ${#PUBLIC_OC_IPS[@]}; i++))
{
    pub_oc_name=${PUBLIC_OC_IPS[$i]}

    # shellcheck disable=SC2086
    echo "Wiping out the ONOS-SONA container and image at ${!pub_oc_name}..."
    ssh sdn@"${!pub_oc_name}" "sudo docker system prune -a || true" > /dev/null
}
