FROM ubuntu:18.04

ENV container docker
ENV SHELL /bin/bash

# Don't start any optional services except for the few we need.
RUN find /etc/systemd/system \
    /lib/systemd/system \
    -path '*.wants/*' \
    -not -name '*journald*' \
    -not -name '*systemd-tmpfiles*' \
    -not -name '*systemd-user-sessions*' \
    -exec rm \{} \;

RUN echo 'APT::Periodic::Update-Package-Lists "0";' > /etc/apt/apt.conf.d/20auto-upgrades && \
    echo 'APT::Periodic::Unattended-Upgrade "0";' >> /etc/apt/apt.conf.d/20auto-upgrades

RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates curl dbus software-properties-common sudo systemd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - && add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
RUN apt-get install -y docker.io


RUN systemctl set-default multi-user.target && \
    systemctl mask dev-hugepages.mount sys-fs-fuse-connections.mount

RUN  mkdir -p /stack
COPY . /stack

RUN useradd -m docker -g docker && echo "docker:docker" | chpasswd && \
    adduser docker sudo && \
    echo "docker ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Install all of the HashiCorp tooling

RUN chmod +x /stack/build/*.sh && \
    for script in $(ls /stack/build/*.sh | sort ); do FROMDOCKER=1 $script; done

RUN apt-get install -y awscli

RUN apt-get install -y jq
# TODO AWS credentials


STOPSIGNAL SIGRTMIN+3

# Workaround for docker/docker#27202, technique based on comments from docker/docker#9212
CMD ["/bin/bash", "-c", "exec /sbin/init --log-target=journal 3>&1"]