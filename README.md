# Toolset for Managing ONOS Container Cluster

This project contains a set of toolset which is used for managing ONOS cluster at docker environment. We assume that the users have configured at least one linux node (remote machine) to run docker container. Also the local machine where we run toolset, accesses to remote machine through SSH tunnel without providing any password. To accomplish this, we recommend the users to pre-create an user named "sdn" at all remote machines; distribute public RSA key from local machine to all remote machines. With this, local machine does not need to provide password when it accesses to remote machines.

To run the provided toolset locally, the machine should be installed python, git, and ssh related utilities (e.g., ssh-keygen, ssh-copy-id, etc.)

1. Download this toolset.
```
$ git clone https://github.com/sonaproject/onos-docker-tool.git
```

2. Create "sdn" users at all remote machines.

3. Generate private/public RSA key pair at local machine.

```
$ ssh-keygen -t rsa
```

4. Open bash_profile and configure remote machines's IP addresses. Note that those IP addresses should be accessable from local machine. Please add or remove IPs to fulfill your requirement.
```
export OC1=192.168.56.101
export OC2=192.168.56.102
export OC3=192.168.56.103
```

In case you need to assign internally accessable IP addresses to form an ONOS cluster, please configure OC_IPS varaible. Otherwise, this tool will use publically accessable IP addresses (e.g., OC1 ~ OCN) to form an ONOS cluster.
```
export OC_IPS="10.10.10.101 10.10.10.102 10.10.10.103"
```

5. Distribute public RSA key to all remote machines.
```
$ ssh-copy-id $OC1
$ ssh-copy-id $OC2
$ ssh-copy-id $OC3
...
```

6. Provision and launch ONOS container(s) at remote machines.
```
$ ./start.sh
```

7. Stop and remove ONOS containers from all remote machines.
```
$ ./stop.sh
```
