#!/bin/bash

test_cmd_exist() {
    tmp_result="y"
    for item in $1; do
        if [[ x"$(which $1 2>/dev/null)" == "x" ]]; then
            tmp_result="n"
            break
        fi
    done
    echo "$tmp_result"
}

if [[ x"$MY_DOCKER_APP_USER_NAME" == "x" ]]; then
    MY_DOCKER_APP_USER_NAME="xfl"
fi
if [[ x"$MY_DOCKER_APP_USER_GROUP_NAME" == "x" ]]; then
    MY_DOCKER_APP_USER_GROUP_NAME="$MY_DOCKER_APP_USER_NAME"
fi
if [[ x"$MY_DOCKER_APP_USER_HOME" == "x" ]]; then
    MY_DOCKER_APP_USER_HOME="/home/${MY_DOCKER_APP_USER_NAME}"
fi
if [[ x"$MY_DOCKER_APP_USER_SHELL" == "x" ]]; then
    if [[ "$(test_cmd_exist bash)" == "y" ]]; then
        MY_DOCKER_APP_USER_SHELL="/bin/bash"
    else
        MY_DOCKER_APP_USER_SHELL="/bin/sh"
    fi
fi
if [[ x"$MY_DOCKER_APP_USER_ADD_GROUP" == "x" ]]; then
    MY_DOCKER_APP_USER_ADD_GROUP=""
fi
export MY_DOCKER_APP_USER_NAME=$MY_DOCKER_APP_USER_NAME
export MY_DOCKER_APP_USER_HOME=$MY_DOCKER_APP_USER_HOME
export MY_DOCKER_APP_USER_SHELL=$MY_DOCKER_APP_USER_SHELL
export MY_DOCKER_APP_USER_GROUP_NAME=$MY_DOCKER_APP_USER_GROUP_NAME
export MY_DOCKER_APP_USER_ADD_GROUP=$MY_DOCKER_APP_USER_ADD_GROUP

if [ -n "$TZ" ]; then
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
    echo $TZ > /etc/timezone
fi

# echo "Before: PUID[$PUID] PGID[$PGID]"
if [[ x"$PUID" == "x" ]]; then
    PUID=1000
fi
if [[ x"$PGID" == "x" ]]; then
    PGID=$PUID
fi
export PUID=$PUID
export PGID=$PGID
# echo "After: PUID[$PUID] PGID[$PGID]"

# sed -i "/:x:$PUID:$PUID:/d" /etc/passwd
# sed -i "/:x:$PGID:/d" /etc/group

old_username_uid="$(id -u $MY_DOCKER_APP_USER_NAME 2>/dev/null)"
old_uid_username="$(id -n -u $PUID 2>/dev/null)"
old_groupname_id="$(getent group $MY_DOCKER_APP_USER_NAME 2>/dev/null| awk -F':' '{print $NF}')"
old_id_groupname="$(getent group $PGID 2>/dev/null| awk -F':' '{print $1}')"

if [[ x"${old_username_uid}" != "x" ]]; then
    deluser $MY_DOCKER_APP_USER_NAME
fi
if [[ x"${old_uid_username}" != "x" ]]; then
    deluser $old_uid_username
fi
if [[ x"${old_groupname_id}" != "x" ]]; then
    delgroup $MY_DOCKER_APP_USER_NAME
fi
if [[ x"${old_id_groupname}" != "x" ]]; then
    delgroup $old_id_groupname
fi


# if [[ x"$(which useradd 2>/dev/null)" != "x" && x"$(which useradd 2>/dev/null)" != "x" ]]; then
if [[ "$(test_cmd_exist 'groupadd useradd usermod')" == "y" ]]; then
    groupadd --gid $PGID $MY_DOCKER_APP_USER_GROUP_NAME
    useradd -g $MY_DOCKER_APP_USER_GROUP_NAME -u $PUID -s $MY_DOCKER_APP_USER_SHELL -d "$MY_DOCKER_APP_USER_HOME" $MY_DOCKER_APP_USER_NAME
    for item in $(echo "$MY_DOCKER_APP_USER_ADD_GROUP" | tr ',' ' '); do
        groupadd --gid $item $item
        usermod -aG $item $MY_DOCKER_APP_USER_NAME
    done
else
    if [[ "$(busybox --list | grep adduser)" == "adduser" && "$(busybox --list | grep addgroup)" == "addgroup" ]]; then
        busybox addgroup -g $PGID $MY_DOCKER_APP_USER_GROUP_NAME
        busybox adduser -D -s $MY_DOCKER_APP_USER_SHELL -h "$MY_DOCKER_APP_USER_HOME" -u $PUID -G $MY_DOCKER_APP_USER_GROUP_NAME $MY_DOCKER_APP_USER_NAME
        for item in $(echo "$MY_DOCKER_APP_USER_ADD_GROUP" | tr ',' ' '); do
            busybox addgroup -g $item $item
            busybox adduser $MY_DOCKER_APP_USER_NAME $item
        done
    else
        addgroup --gid $PGID $MY_DOCKER_APP_USER_GROUP_NAME
        adduser --shell $MY_DOCKER_APP_USER_SHELL --home "$MY_DOCKER_APP_USER_HOME" --uid $PUID --gid $PGID --disabled-password --no-create-home --gecos "" $MY_DOCKER_APP_USER_NAME
        for item in $(echo "$MY_DOCKER_APP_USER_ADD_GROUP" | tr ',' ' '); do
            addgroup --gid $item $item
            adduser $MY_DOCKER_APP_USER_NAME $item
        done
    fi
fi

# 为了兼容 link 目录，当且仅当两者均判断为否时，才创建文件夹
if [ ! -d "$MY_DOCKER_APP_USER_HOME" -a ! -f "$MY_DOCKER_APP_USER_HOME" ]; then
    mkdir -p "$MY_DOCKER_APP_USER_HOME"
fi
chown $MY_DOCKER_APP_USER_NAME:$MY_DOCKER_APP_USER_NAME -Rh "$MY_DOCKER_APP_USER_HOME"

