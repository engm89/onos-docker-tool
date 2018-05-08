# Toolset for Managing ONOS Cluster at Docker Environment

This project contains a set of toolset which is used for managing ONOS cluster at docker environment. We assume that the users have configured at least one linux node (remote machine) to run docker container. Also the local machine where we run toolset, accesses to remote machine through SSH tunnel without providing any password. To accomplish this, we recommend the users to pre-create an user named "sdn" at all remote machines; distribute public RSA key from local machine to all remote machines. With this, local machine does not need to provide password when it accesses to remote machines.

To run the provided toolset locally, the machine should be installed python, git, and ssh related utilities (e.g., ssh-keygen, ssh-copy-id, etc.)

1. Download this toolset.
```
$ git clone https://github.com/sonaproject/onos-docker-tool.git
```

2. Create "sdn" users at all remote machines.

3. Parameterize remote machines's IP address into bash_profile. By default we configured three ONOS nodes's IP address. Please add or remove IPs to fulfill your requirement.
```
$ cat bash_profile
export OC1=192.168.56.101
export OC2=192.168.56.102
export OC3=192.168.56.103
```

Apply the environment variables as follow.
```
$ source ./bash_profile
```

4. Generate private/public RSA key pair at local machine.

```
$ ssh-keygen -t rsa
```

5. Distribute public RSA key to all remote machine.
```
$ ssh-copy-id $OC1
$ ssh-copy-id $OC2
$ ssh-copy-id $OC3
...
```

6. Provision and launch ONOS at remote machines.
```
$ ./start.sh $OC1 $OC2 $OC3 ...
```

7. Stop and remove ONOS from remote machines.
```
$ ./stop.sh $OC1 $OC2 $OC3 ...
```
