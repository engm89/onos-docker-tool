FROM alpine:latest
MAINTAINER Jian Li <gunine@sk.com>

# add ssh and iptables
RUN apk add --no-cache \
            openssh \
            sshpass \
            wget \
            curl \
            bash \
            python \
            python-dev \
            py-pip

# add entrypoint script
COPY docker-entrypoint.sh /runssh.sh
RUN chmod +x /runssh.sh

# copy onos-docker-tool
RUN mkdir -p /odt/bin && \
    mkdir -p /odt/site/default && \
    mkdir -p /odt/asset

COPY *.sh /odt/
COPY bash_profile /odt/
COPY envSetup /odt/
COPY asset /odt/asset
COPY bin /odt/bin
COPY site/default /odt/site/default

RUN rm -rf /etc/ssh/ssh_host_rsa_key /etc/ssh/ssh_host_dsa_key

RUN mkdir /var/run/sshd

# permit root ssh
RUN sed -i -e '/^PermitRootLogin/s/^.*$/PermitRootLogin yes/' /etc/ssh/sshd_config

# accept SSH connection
EXPOSE 22

# configure work directory
WORKDIR /odt

ENTRYPOINT ["/runssh.sh"]
CMD ["/usr/sbin/sshd", "-D"]
