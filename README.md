# Management Tools of Container-based ONOS Cluster (MTCO)

The MTCO contains a set of tools for managing a container based ONOS cluster. We assume that the users have configured at least one linux node (remote machine) which is capable for running a docker container. Also the local machine where we run the MTCO has privilege to access to the remote machine through SSH tunnel without providing the password. To achieve this, the users need to 1) pre-create an user named "sdn" at all remote machines; 2) distribute a public RSA key from the local machine to all remote machines. With this setup, the local machine does not need to provide any password when it accesses to the remote machines.

To run MTCO, the local machine should be installed `python`, `git`, and ssh related softwares such as `ssh-keygen`, `ssh-copy-id`, etc. Since the user may use any UNIX-based OS, therefore the installation instruction of prerequisite softwares will be varied, we will not provide the detailed installation instruction on those softwares.

1. Download this toolset.
```
$ git clone https://github.com/sonaproject/onos-docker-tool.git
```

2. Create the "sdn" users at all remote machines.
```
# useradd sdn
# echo "sdn ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
# passwd sdn
```

3. Generate a private/public RSA key pair at the local machine.
```
$ ssh-keygen -t rsa
```

4. Open bash_profile and configure the remote machines's IP addresses. Note that those IP addresses should be accessable from the local machine. Please add or remove IPs to fulfill your requirement.
```
export OC1=192.168.56.101
export OC2=192.168.56.102
export OC3=192.168.56.103
```

In case you need to assign internally accessable IP addresses (which are not accessable from the local machine) to form an ONOS cluster, please configure an OC_IPS variable. Otherwise, this toolset will use the publically accessable IP addresses (e.g., OC1 ~ OCN) to form an ONOS cluster.
```
export OC_IPS="10.10.10.101 10.10.10.102 10.10.10.103"
```

5. Distribute the public RSA key to all remote machines.
```
$ ssh-copy-id sdn@$OC1
$ ssh-copy-id sdn@$OC2
$ ssh-copy-id sdn@$OC3
...
```

6. Provision and launch the ONOS container(s) at the remote machines.
```
$ ./start.sh
```

7. Stop and remove the ONOS containers from all the remote machines.
```
$ ./stop.sh
```
