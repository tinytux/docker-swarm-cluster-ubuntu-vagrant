#!/bin/bash
set -eux

ip=$1
first_node_ip=$2
node_number=$3

# if this is the first node, init the swarm, otherwise, join it.
if [ "$ip" == "$first_node_ip" ]; then
    # remove previous join tokens (in case they exist).
    rm -f /vagrant/shared/docker-swarm-join-token-*

    # init the swarm.
    docker swarm init \
        --data-path-addr $ip \
        --listen-addr "$ip:2377" \
        --advertise-addr "$ip:2377" # or 'eth1:2377'

    # save the swarm join tokens into the shared folder.
    mkdir -p /vagrant/shared
    docker swarm join-token manager -q >/vagrant/shared/docker-swarm-join-token-manager.txt
    docker swarm join-token worker -q >/vagrant/shared/docker-swarm-join-token-worker.txt
else
    # make first 3 nodes managers, all others workers
    role="manager"
    if [ $node_number -gt 3 ]; then
        role="worker"
    fi

    # join the swarm
    docker swarm join \
        --token $(cat /vagrant/shared/docker-swarm-join-token-${role}.txt) \
        "$first_node_ip:2377"
fi

# kick the tires.
docker version
docker info
docker network ls
ip link
bridge link
docker run --rm alpine cat /etc/resolv.conf
