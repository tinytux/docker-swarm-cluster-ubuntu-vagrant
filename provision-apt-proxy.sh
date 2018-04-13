#!/bin/bash
#
# update apt proxy
#

if [ $(id -u) != 0 ]; then
    echo "ERROR: $0 must be be run as root, not as `whoami`" 2>&1
    exit 1
fi

DEBIAN_FRONTEND=noninteractive

DEFAULT_GATEWAY=$(ip route | grep "default via " | cut -d ' ' -f 3)
if ! nc -z ${DEFAULT_GATEWAY} 3142; then
    DEFAULT_GATEWAY=$(nmap ${DEFAULT_GATEWAY}/24 -n -T insane -p3142 -oG - | grep apt-cacher | head -n1 | awk '{print $2}')
fi

echo -n "Waiting for apt to terminate..."
while  [[ -n "$(fuser /var/lib/dpkg/lock >/dev/null 2>&1)" ]]; do
    sleep 2
    echo -n "."
done
echo "OK"

if [[ ! -n "$(grep  "Acquire::http::Proxy" /etc/apt/apt.conf)" ]]; then

    if [[ ! -e /bin/nc ]]; then
        apt-get update
        apt-get -y install netcat
    fi

    if [[ ! "$(nc -z ${DEFAULT_GATEWAY} 3142)" ]]; then
        echo "Adding apt proxy: ${DEFAULT_GATEWAY}:3142"
        echo "Acquire::http::Proxy \"http://${DEFAULT_GATEWAY}:3142\";" >>/etc/apt/apt.conf
    else
        echo "No apt proxy detected."
    fi
else
    echo "Updating apt proxy: ${DEFAULT_GATEWAY}:3142"
    sed -r 's/(\b[0-9]{1,3}\.){3}[0-9]{1,3}:3142\b'/${DEFAULT_GATEWAY}:3142/ -i /etc/apt/apt.conf
fi

apt-get update

