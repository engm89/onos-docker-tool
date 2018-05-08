#!/bin/bash
nodes=("$@")

if [ $# -eq 0 ]; then
    echo "ONOS controller IPs have not been provided. Please specify one."
    exit 1
fi

# stop & remove ONOS-SONA container
echo "Removing ONOS-SONA docker image..."

for ((i=0; i < $#; i++))
{
    ssh sdn@${nodes[$i]} "sudo docker stop onos || true"
    ssh sdn@${nodes[$i]} "sudo docker rm onos || true"
}

# remove ONOS configuration directory
for ((i=0; i < $#; i++))
{
    ssh sdn@${nodes[$i]} "rm -rf ~/onos_config"
}
