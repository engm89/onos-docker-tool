#!/bin/bash
nodes=("$@")

if [ $# -eq 0 ]; then
    echo "ONOS controller IPs have not been provided. Please specify one."
    exit 1
fi

# start pull ONOS-SONA docker image, stop & remove ONOS-SONA container
echo "Pulling ONOS-SONA docker image..."

for ((i=0; i < $#; i++))
{
    ssh sdn@${nodes[$i]} "sudo docker pull gunine/onos-sona-docker:1.13.0"
    ssh sdn@${nodes[$i]} "sudo docker stop onos || true"
    ssh sdn@${nodes[$i]} "sudo docker rm onos || true"
}

# generate and inject cluster.json file
echo "Generating cluster.json..."
rm -rf /tmp/cluster.json
ips=""
for ((i=0; i < $#; i++))
{
    ips="$ips ${nodes[$i]}"
}
python onos-gen-partitions /tmp/cluster.json $ips

# copy ONOS configuration files under onos_config directory
echo "Copying ONOS configs..."

for ((i=0; i < $#; i++))
{
    ssh sdn@${nodes[$i]} "rm -rf ~/onos_config"
    ssh sdn@${nodes[$i]} "mkdir -p ~/onos_config"
    scp /tmp/cluster.json sdn@${nodes[$i]}:~/onos_config
}

# start ONOS-SONA container
echo "Launching ONOS cluster..."
for ((i=0; i < $#; i++))
{
    ssh sdn@${nodes[$i]} "sudo docker run --rm -itd --network host --name onos -v ~/onos_config:/root/onos/config gunine/onos-sona-docker:1.13.0"
}
