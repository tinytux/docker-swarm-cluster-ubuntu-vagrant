#!/bin/bash
set -eux

# prevent apt-get et al from asking questions.
# NB even with this, you'll still get some warnings that you can ignore:
#     dpkg-preconfigure: unable to re-open stdin: No such file or directory
export DEBIAN_FRONTEND=noninteractive

# install docker.
# see https://docs.docker.com/engine/installation/linux/docker-ce/ubuntu/#install-using-the-repository
apt-get install -y apt-transport-https software-properties-common
wget -qO- https://download.docker.com/linux/ubuntu/gpg | apt-key add -

UBUNTU_RELEASE="$(lsb_release -cs)"
# Bionic release not available today - artful seems to work as fallback.
if [[ ${UBUNTU_RELEASE} == "bionic" ]]; then
    UBUNTU_RELEASE="artful"
fi
add-apt-repository "deb [arch=amd64] http://download.docker.com/linux/ubuntu ${UBUNTU_RELEASE} stable"
apt-get update
apt-get install -y docker-ce

# configure it.
systemctl stop docker
cat >/etc/docker/daemon.json <<'EOF'
{
    "labels": [
        "os=linux"
    ],
    "hosts": [
        "fd://",
        "tcp://0.0.0.0:2375"
    ]
}
EOF
sed -i -E 's,^(ExecStart=/usr/bin/dockerd).*,\1,' /lib/systemd/system/docker.service
systemctl daemon-reload
systemctl start docker

# let the vagrant user manage docker.
usermod -aG docker vagrant

# kick the tires.
docker version
docker info
docker network ls
ip link
bridge link
docker run --rm hello-world
docker run --rm alpine cat /etc/resolv.conf
#docker run --rm alpine ping -c1 8.8.8.8
