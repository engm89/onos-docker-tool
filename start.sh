#!/bin/bash
# -----------------------------------------------------------------------------
# ONOS container provisioning shell script.
# -----------------------------------------------------------------------------

function _usage () {
cat << _EOF_
usage: $(basename "$0")

VERSION:
  ONOS version

ONOS container provisioning shell script.

The shell script will refer to environment variables defined in bash_profile to
provision ONOS containers.

_EOF_
}

REPO_PATH="opensona"
ONOS_REPO_NAME="onos-sona-nightly-docker"
ATOMIX_REPO_NAME="atomix-docker"
ONOS_REPO_TAG="dev"
ATOMIX_REPO_TAG="latest"

[ "$1" = "-h" ] || [ "$1" = '-?' ] && _usage && exit 0

echo $REPO_TAG

# shellcheck disable=SC1091
source envSetup

if [ ${#ACCESS_IPS[@]} -eq 0 ]; then
    echo "No ONOS Controller IP addresses were configured!"
    echo "Please configure IP address in bash_profile."
    exit 1
fi

echo "Following IP addresses will be used to spawn ONOS containers."
for ((i=0; i < ${#ACCESS_IPS[@]}; i++))
{
    oc_name=${ACCESS_IPS[$i]}
    echo "$oc_name = ${!oc_name}"
}

if [ ${#PRIVATE_IPS[@]} -eq 0 ]
then
    echo "ONOS Cluster IP addresses were NOT configured!"
    echo "Following IP address will be used to form an ONOS cluster."
    for ((i=0; i < ${#ACCESS_IPS[@]}; i++))
    {
        oc_name=${ACCESS_IPS[$i]}
        echo "$oc_name = ${!oc_name}"
    }

else
    echo "ONOS Cluster IP addresses were configured!"
    echo "Following IP address will be used to form an ONOS cluster."
    for ((i=0; i < ${#PRIVATE_IPS[@]}; i++))
    {
        op_name=${PRIVATE_IPS[$i]}
        echo "$op_name = ${!op_name}"
    }
fi

# start pull ONOS-SONA docker image, stop & remove ONOS-SONA container
echo "Pulling ONOS-SONA, ATOMIX docker image..."

for ((i=0; i < ${#ACCESS_IPS[@]}; i++))
{
    oc_name=${ACCESS_IPS[$i]}

    echo "Pulling ONOS-SONA docker image at ${!oc_name}..."
    ssh sdn@"${!oc_name}" "sudo docker pull $REPO_PATH/$ONOS_REPO_NAME:$ONOS_REPO_TAG"

    # shellcheck disable=SC2086
    if [ "$(ssh sdn@${!oc_name} 'sudo docker ps -q -a -f name=onos')" ]; then
        echo "Wiping out existing ONOS-SONA container at ${!oc_name}..."
        ssh sdn@"${!oc_name}" "sudo docker stop onos || true" > /dev/null
        ssh sdn@"${!oc_name}" "sudo docker rm onos || true" > /dev/null
    fi

    echo "Pulling ATOMIX docker image at ${!oc_name}..."
    ssh sdn@"${!oc_name}" "sudo docker pull $REPO_PATH/$ATOMIX_REPO_NAME:$ATOMIX_REPO_TAG"

    # shellcheck disable=SC2086
    if [ "$(ssh sdn@${!oc_name} 'sudo docker ps -q -a -f name=atomix')" ]; then
        echo "Wiping out existing ATOMIX container at ${!oc_name}..."
        ssh sdn@"${!oc_name}" "sudo docker stop atomix || true" > /dev/null
        ssh sdn@"${!oc_name}" "sudo docker rm atomix || true" > /dev/null
    fi
}

ips=""
if [ ${#PRIVATE_IPS[@]} -eq 0 ]
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
  for ((i=0; i < ${#PRIVATE_IPS[@]}; i++))
  {
      oc_name=${PRIVATE_IPS[$i]}
      if [ $i -eq 0 ]
      then
          ips="${!oc_name}"
      else
          ips="$ips ${!oc_name}"
      fi
  }
fi

echo $ips

# copy ONOS configuration files under onos_config directory
echo "Copying ONOS configs..."
for ((i=0; i < ${#ACCESS_IPS[@]}; i++))
{
    oc_name=${ACCESS_IPS[$i]}

    if [ ${#PRIVATE_IPS[@]} -eq 0 ]
    then
      op_name=${ACCESS_IPS[$i]}
    else
      op_name=${PRIVATE_IPS[$i]}
    fi

    ssh sdn@"${!oc_name}" "rm -rf ~/atomix_config"
    ssh sdn@"${!oc_name}" "mkdir -p ~/atomix_config"
    ssh sdn@"${!oc_name}" "rm -rf ~/onos_config"
    ssh sdn@"${!oc_name}" "mkdir -p ~/onos_config"

    # generate and inject atomix.json file
    echo "Generating atomix.json..."
    ATOMIX_CDEF_FILE=/tmp/"${!oc_name}".atomix.json
    rm -rf $ATOMIX_CDEF_FILE
    python asset/atomix-gen-config ${!op_name} $ATOMIX_CDEF_FILE $ips
    scp -q $ATOMIX_CDEF_FILE sdn@"${!oc_name}":~/atomix_config/atomix.json

    # generate and inject cluster.json file
    echo "Generating cluster.json..."
    ONOS_CDEF_FILE=/tmp/"${!oc_name}".cluster.json
    rm -rf $ONOS_CDEF_FILE
    python asset/onos-gen-config ${!op_name} $ONOS_CDEF_FILE --nodes $ips
    scp -q $ONOS_CDEF_FILE sdn@"${!oc_name}":~/onos_config/cluster.json

    # copy component-config file if it exists
    if [ -f $ONOS_DOCKER_SITE_ROOT/$ONOS_DOCKER_SITE/component-cfg.json ]
    then
      scp $ONOS_DOCKER_SITE_ROOT/$ONOS_DOCKER_SITE/component-cfg.json sdn@"${!oc_name}":~/onos_config
    fi
}

# start ONOS-SONA container
echo "Launching ONOS cluster..."
for ((i=0; i < ${#ACCESS_IPS[@]}; i++))
{
    oc_name=${ACCESS_IPS[$i]}
    ssh sdn@"${!oc_name}" "sudo docker run -itd --network host --name atomix -v ~/atomix_config:/root/atomix/config $REPO_PATH/$ATOMIX_REPO_NAME:$ATOMIX_REPO_TAG"
    ssh sdn@"${!oc_name}" "sudo docker run -itd --network host --name onos -v ~/onos_config:/root/onos/config $REPO_PATH/$ONOS_REPO_NAME:$ONOS_REPO_TAG"
    ssh sdn@"${!oc_name}" "sudo docker ps"
}

echo "Done!"
