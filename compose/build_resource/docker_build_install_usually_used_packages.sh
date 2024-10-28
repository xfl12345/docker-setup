#!/bin/sh
# cd "$(dirname "$(readlink -f "$0")")"
cd /tmp/xfl/build_resource/
os_release_id="$(cat /etc/os-release | grep '^ID=')"
if [ ! -z "$os_release_id" ]; then
    os_name="$(echo $os_release_id | cut -d'=' -f2 | tr '[:upper:]' '[:lower:]')"
    if [ "$os_name" = "alpine" ]; then
        apk add $(cat ./alpine_usually_used_packages.txt)
    elif [ "$os_name" = "debian" ] || [ "$os_name" = "ubuntu" ]; then
        apt install -y $(cat ./ubuntu_usually_used_packages.txt)
    else
        echo "Unsupported system[${os_name}]"
        exit 1
    fi
fi
