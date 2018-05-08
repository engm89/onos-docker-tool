# Toolset for Managing ONOS Cluster at Docker Environment

This project contains a set of toolset which is used for managing ONOS cluster at docker environment. We assume that the users have configured at least one linux node where docker is running. Also the local machine where the toolset is running, can access to remote machine where ONOS is running, without providing any password. We recommend the users to pre-create an user namely "sdn" to all remote machines and distribute public RSA key from local machine to all remote machines. With this configuration, local machine does not need to provide password when it accesses remote machine.

1. Download toolset.
```
$ git clone https://github.com/sonaproject/onos-docker-tool.git
```

2. Create "sdn" users to all remote machines.

3. Parameterize remote machines's IP address into bash_profile. 

4. Generate private/public RSA key pair at local machine.

```
$ ssh-keygen -t rsa
```

5. Distribute public RSA key to all remote machine.
```
$ ssh-copy-id IP_OF_REMOTE_MACHINE_1 IP_OF_REMOTE_MACHINE_2
```

6. Provision and start ONOS in remote machines.
```
$ ./start.sh $OC1 $OC2 ...
```

7. Stop and remove ONOS in remote machines.
```
$ ./stop.sh $OC1 $OC2 ...
```
