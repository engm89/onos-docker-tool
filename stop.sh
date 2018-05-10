#!/bin/bash
nodes=("$@")

ENV_VAR=`env | awk -F "=" '{print $1}' | grep "^OC[0-9]$"`
ACCESS_IPS=($ENV_VAR)
OC_IPS_ALT=""

for ((i=0; i < ${#ACCESS_IPS[@]}; i++))
{
    oc_name=${ACCESS_IPS[$i]}
    unset $oc_name
}
unset OC_IPS

. bash_profile

if [ ${#ACCESS_IPS[@]} -eq 0 ]; then
    echo "No ONOS Controller IP addresses were configured! Please configure IP address in bash_profile."
    exit 1
fi

# stop & remove ONOS-SONA container
echo "Removing ONOS-SONA docker image..."

for ((i=0; i < ${#ACCESS_IPS[@]}; i++))
{
    oc_name=${ACCESS_IPS[$i]}

    ssh sdn@${!oc_name} "sudo docker stop onos || true"
    ssh sdn@${!oc_name} "sudo docker rm onos || true"
}

# remove ONOS configuration directory
echo "Removing ONOS configuration directory..."

for ((i=0; i < ${#ACCESS_IPS[@]}; i++))
{
    oc_name=${ACCESS_IPS[$i]}

    ssh sdn@${!oc_name} "rm -rf ~/onos_config"
}
