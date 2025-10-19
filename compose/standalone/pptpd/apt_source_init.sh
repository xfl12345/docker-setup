#!/usr/bin/env bash
# apt update
# apt install -y apt-transport-*
export CURRENT_DISTRIB_CODENAME="$(cat /etc/lsb-release  | grep 'DISTRIB_CODENAME' | cut -d'=' -f 2)"
export CURRENT_DISTRIB_ID="$(cat /etc/lsb-release  | grep 'DISTRIB_ID' | cut -d'=' -f 2)"
ubuntu_moved_source_message='# Ubuntu sources have moved to /etc/apt/sources.list.d/ubuntu.sources'
ARCH="$(uname -m)"
apt_config=""
if [ -f /tmp/the-geo ] && [[ "$(cat /tmp/the-geo)" == "CN" ]]; then
    if [[ "$ARCH" == "x86_64" ]]; then
        apt_config=$(cat << EOF
Types: deb
URIs: http://mirrors.aliyun.com/ubuntu/
Suites: ${CURRENT_DISTRIB_CODENAME} ${CURRENT_DISTRIB_CODENAME}-updates ${CURRENT_DISTRIB_CODENAME}-backports ${CURRENT_DISTRIB_CODENAME}-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

EOF
)
    else
        apt_config=$(cat << EOF
Types: deb
URIs: http://mirrors.aliyun.com/ubuntu-ports/
Suites: ${CURRENT_DISTRIB_CODENAME} ${CURRENT_DISTRIB_CODENAME}-updates ${CURRENT_DISTRIB_CODENAME}-backports ${CURRENT_DISTRIB_CODENAME}-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg

EOF
)
    fi
fi

[[ "$CURRENT_DISTRIB_ID" == "Ubuntu" ]] && test -e /etc/apt/sources.list && [[ "$(cat /etc/apt/sources.list | head -n1)" != "$ubuntu_moved_source_message" ]] && echo "$ubuntu_moved_source_message" > /etc/apt/sources.list && echo -e "${apt_config}" > /etc/apt/sources.list.d/ubuntu.sources

# cat /tmp/the-geo
# cat /etc/lsb-release
# cat /etc/apt/sources.list
# cat /etc/apt/sources.list.d/ubuntu.sources
# sleep 20
