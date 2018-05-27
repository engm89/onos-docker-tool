#!/bin/bash
# -----------------------------------------------------------------------------
# ONOS container provisioning shell script.
# -----------------------------------------------------------------------------

function _usage () {
cat << _EOF_
usage: $(basename "$0")

ONOS container provisioning shell script.

The shell script will refer to environment variables defined in bash_profile to
provision ONOS containers.

_EOF_
}

[ "$1" = "-h" ] || [ "$1" = '-?' ] && _usage && exit 0

# shellcheck disable=SC1091
source envSetup
ODC_IPS_ALT=""

if [ ${#ACCESS_IPS[@]} -eq 0 ]; then
    echo "No ONOS Controller IP addresses were configured!"
    echo "Please configure IP address in bash_profile."
    exit 1
fi

echo "Following IP addresses will be used to spawn ONOS containers."
for ((i=0; i < ${#ACCESS_IPS[@]}; i++))
{
    oc_name=${ACCESS_IPS[$i]}
    ODC_IPS_ALT="$ODC_IPS_ALT ${!oc_name}"
    echo "$oc_name = ${!oc_name}"
}

if [ -z "$ODC_IPS" ]
then
    echo "ONOS Cluster IP addresses were NOT configured!"
    echo "Following IP address will be used to form an ONOS cluster."
    echo "$ODC_IPS_ALT"

else
    echo "ONOS Cluster IP addresses were configured!"
    echo "Following IP address will be used to form an ONOS cluster."
    echo "$ODC_IPS"
fi

# start pull ONOS-SONA docker image, stop & remove ONOS-SONA container
echo "Pulling ONOS-SONA docker image..."

for ((i=0; i < ${#ACCESS_IPS[@]}; i++))
{
    oc_name=${ACCESS_IPS[$i]}

    echo "Pulling ONOS-SONA docker image at ${!oc_name}..."
    ssh sdn@"${!oc_name}" "sudo docker pull opensona/onos-sona-nightly-docker"

    # shellcheck disable=SC2086
    if [ "$(ssh sdn@${!oc_name} 'sudo docker ps -q -a -f name=onos')" ]; then
        echo "Wiping out existing ONOS-SONA container at ${!oc_name}..."
        ssh sdn@"${!oc_name}" "sudo docker stop onos || true" > /dev/null
        ssh sdn@"${!oc_name}" "sudo docker rm onos || true" > /dev/null
    fi
}

# generate and inject cluster.json file
echo "Generating cluster.json..."
rm -rf /tmp/cluster.json
ips=""
if [ -z "$ODC_IPS" ]
then
    for ((i=0; i < ${#ACCESS_IPS[@]}; i++))
    {
        oc_name=${ACCESS_IPS[$i]}
        if [ $i -eq 0 ]
        then
            ips="${!oc_name}"
        else
            ips="$ips ${!oc_name}"
        fi
    }
else
    ips=$ODC_IPS
fi

# shellcheck disable=SC2086
python asset/onos-gen-partitions /tmp/cluster.json $ips

# copy ONOS configuration files under onos_config directory
echo "Copying ONOS configs..."
for ((i=0; i < ${#ACCESS_IPS[@]}; i++))
{
    oc_name=${ACCESS_IPS[$i]}
    ssh sdn@"${!oc_name}" "rm -rf ~/onos_config"
    ssh sdn@"${!oc_name}" "mkdir -p ~/onos_config"

    # copy cluster.json config file
    scp /tmp/cluster.json sdn@"${!oc_name}":~/onos_config

    # copy component-config file
    scp $ONOS_DOCKER_SITE_ROOT/$ONOS_DOCKER_SITE/component-cfg.json sdn@"${!oc_name}":~/onos_config
}

# start ONOS-SONA container
echo "Launching ONOS cluster..."
for ((i=0; i < ${#ACCESS_IPS[@]}; i++))
{
    oc_name=${ACCESS_IPS[$i]}
    ssh sdn@"${!oc_name}" "sudo docker run -itd --network host --name onos -v ~/onos_config:/root/onos/config opensona/onos-sona-nightly-docker"
    ssh sdn@"${!oc_name}" "sudo docker ps"
}

echo "Done!"
