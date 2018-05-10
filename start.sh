#!/bin/bash

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

echo "Following IP addresses will be used to spawn ONOS containers."
for ((i=0; i < ${#ACCESS_IPS[@]}; i++))
{
    oc_name=${ACCESS_IPS[$i]}
    OC_IPS_ALT="$OC_IPS_ALT ${!oc_name}"
    echo "$oc_name = ${!oc_name}"
}

if [ -z "$OC_IPS" ]
then
    echo "ONOS Cluster IP addresses were NOT configured! Following IP address will be used to form an ONOS cluster."
    echo "$OC_IPS_ALT"

else
    echo "ONOS Cluster IP addresses were configured! Following IP address will be used to form an ONOS cluster."
    echo "$OC_IPS"
fi

# start pull ONOS-SONA docker image, stop & remove ONOS-SONA container
echo "Pulling ONOS-SONA docker image..."

for ((i=0; i < ${#ACCESS_IPS[@]}; i++))
{
    oc_name=${ACCESS_IPS[$i]}
    ssh sdn@${!oc_name} "sudo docker pull opensona/onos-sona-nightly-docker"
    ssh sdn@${!oc_name} "sudo docker stop onos || true"
    ssh sdn@${!oc_name} "sudo docker rm onos || true"
}

# generate and inject cluster.json file
echo "Generating cluster.json..."
rm -rf /tmp/cluster.json
ips=""
if [ -z "$OC_IPS" ]
then
    for ((i=0; i < $#; i++))
    {
        ips="$ips ${nodes[$i]}"
    }
else
    ips=$OC_IPS
fi

python onos-gen-partitions /tmp/cluster.json $ips

# copy ONOS configuration files under onos_config directory
echo "Copying ONOS configs..."
for ((i=0; i < ${#ACCESS_IPS[@]}; i++))
{
    oc_name=${ACCESS_IPS[$i]}
    ssh sdn@${!oc_name} "rm -rf ~/onos_config"
    ssh sdn@${!oc_name} "mkdir -p ~/onos_config"
    scp /tmp/cluster.json sdn@${!oc_name}:~/onos_config
}

# start ONOS-SONA container
echo "Launching ONOS cluster..."
for ((i=0; i < ${#ACCESS_IPS[@]}; i++))
{
    oc_name=${ACCESS_IPS[$i]}
    ssh sdn@${!oc_name} "sudo docker run -itd --network host --name onos -v ~/onos_config:/root/onos/config opensona/onos-sona-nightly-docker"
}

echo "Done!"
