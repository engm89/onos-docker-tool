[![Build Status](https://travis-ci.org/sonaproject/onos-docker-tool.svg?branch=master)](https://travis-ci.org/sonaproject/onos-docker-tool)

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

4. Apply the environment variables by sourcing `bash_profile`. If the user wants to apply the variables for each login, he/she needs to put following content into `.bash_profile` under user directory.
```
. ~/path-to-onos-docker-tool/bash_profile
```

5. Create the site profile which contains cell and a set of ONOS configuration files. A cell is similar to ONOS cell which includes a set of environment variables such as ODC1 ~ ODCX, ODC_IPS, etc. Those variables will be referred from MTCO for container provision and teardown. All profile should be located under `site` directory with its own name. By default, we provide a profile named `default`. Please refer to default to create your own site profile. After done all site profile creation, please apply the profile by issuing following commands.
```
$ onos-docker-site profile_name
```
`onos-docker-site` can be further simplified with `ods`.

6. Distribute the public RSA key to all remote machines.
```
$ ssh-copy-id sdn@$ODC1
$ ssh-copy-id sdn@$ODC2
$ ssh-copy-id sdn@$ODC3
...
```

7. Provision and launch the ONOS container(s) at the remote machines.
```
$ ./start.sh
```

8. Push `network-cfg.json` to one of the ONOS nodes.
```
$ ./push-cfg.sh
```

9. Access to ONOS shell.
```
$ onos-docker $ODC1
```
Note that, `onos-docker` can be further simplified with `od`. In order to use `onos-docker` command, please install `sshpass` utility first.
The following link describes how to install `sshpass`. https://gist.github.com/arunoda/7790979

10. View ONOS log.
```
$ onos-docker-log $ODC1
```
Note that, `onos-docker-log` can be further simplified with `odl`. `odl` does NOT stand for `opendaylight` :)

11. Stop and remove the ONOS containers from all the remote machines.
```
$ ./stop.sh
```
