#!/bin/bash

# my_ifs=' '
# for (( i=0; i<${#IFS}; i++ )); do
#     local char="${IFS:i:1}"
#     case "$char" in
#         $'\n')
#             char='\n'
#             ;;
#         $'\t')
#             char='\t'
#             ;;
#         ' ')
#             char=' '
#             ;;
#         *)
#             ; # do nothing
#             ;;
#     esac
#     # if [[ "${#char}" -eq 1 ]]; then
#     #     my_ifs="$char"
#     #     break
#     # fi
# done

just_get_ifs_char() {
    local my_ifs=${IFS:0:1}
    case "$my_ifs" in
        $'\n')
            my_ifs='\n'
            ;;
        $'\t')
            my_ifs='\t'
            ;;
        ' ')
            my_ifs=' '
            ;;
        *)
            my_ifs=$my_ifs # do nothing
            ;;
    esac
    if [[ x"$my_ifs" == "x" ]]; then
        my_ifs='\n'
    fi
    echo "$my_ifs"
}

test_cmd_exist() {
    local tmp_result="y"
    for item in $(echo "$1" | tr ' ' "$(just_get_ifs_char)"); do
        # if [[ x"$(which $item 2>/dev/null)" == "x" ]]; then
        #     tmp_result="n"
        #     break
        # fi
        command -v "$item" >/dev/null 2>&1
        if [[ x"$?" != "x0" ]]; then
            tmp_result="n"
            break
        fi
    done
    echo "$tmp_result"
}

# if [[ "$(test_cmd_exist 'groupadd useradd usermod')" == "y" ]]; then
#     # $1 group name
#     # $2 group ID
#     my_create_group() {
#         groupadd --gid $2 $1
#     }

#     # $1 group ID list
#    my_create_groups() {
#        for item in $(echo "$1" | tr ',' ' '); do
#            item=$((10#$item))
#            local _group_name="$(getent group $item 2>/dev/null| awk -F':' '{print $1}')"
#            if [[ -z "$_group_name" ]]; then
#                _group_name=$item
#            fi
#            my_create_group $_group_name $item
#        done
#    }

#     # $1 user name
#     # $2 user group name
#     # $3 user ID
#     # $4 user extra group name list
#     # $5 user shell
#     # $6 user home
#     my_create_user() {
#         local _uname=$1
#         local _gname=$2
#         local _uid=$3
#         local _add_groups=$4
#         local _ushell=$5
#         local _uhome=$6
#         useradd -u $_uid -g $_gname -G $_add_groups -s $_ushell -d "$_uhome" $_uname
#     }

#     # $1 user name
#     # $2 group name
#     my_add_user_to_group() {
#         usermod -aG $2 $1
#     }

# else
# fi

if [ -n "$TZ" ]; then
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
    echo $TZ > /etc/timezone
fi

if [[ x"$MY_DOCKER_APP_USER_NAME" == "x" && x"$PUID" == "x" ]]; then
    PUID=$(id -u)
    old_uid_username="$(id -n -u $PUID 2>/dev/null)"
    if [[ x"$old_uid_username" == "x" ]]; then
        MY_DOCKER_APP_USER_NAME="$PUID"
    else
        MY_DOCKER_APP_USER_NAME="$old_uid_username"
    fi
else
    if [[ x"$MY_DOCKER_APP_USER_NAME" == "x" ]]; then
        MY_DOCKER_APP_USER_NAME="${PUID}"
    else
        if [[ x"$PUID" == "x" ]]; then
            PUID=$(id -u)
        else
            PUID=$((10#$PUID))
        fi
    fi
fi

if [[ x"$PGID" == "x" ]]; then
    PGID=$PUID
else
    PGID=$((10#$PGID))
fi
export PUID=$PUID
export PGID=$PGID
# echo "After: PUID[$PUID] PGID[$PGID]"

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
if [[ x"$MY_DOCKER_APP_USER_ADD_GROUP_ID_LIST" == "x" ]]; then
    MY_DOCKER_APP_USER_ADD_GROUP_ID_LIST=""
fi
export MY_DOCKER_APP_USER_NAME=$MY_DOCKER_APP_USER_NAME
export MY_DOCKER_APP_USER_HOME=$MY_DOCKER_APP_USER_HOME
export MY_DOCKER_APP_USER_SHELL=$MY_DOCKER_APP_USER_SHELL
export MY_DOCKER_APP_USER_GROUP_NAME=$MY_DOCKER_APP_USER_GROUP_NAME
export MY_DOCKER_APP_USER_ADD_GROUP_ID_LIST=$MY_DOCKER_APP_USER_ADD_GROUP

if [[ "${MY_DOCKER_APP_USER_NAME}" == "root" ]]; then
    if [[ "$(test_cmd_exist 'usermod')" == "n" ]]; then
        echo "Failed to initialize environment due to missing command [usermod]."
        exit 1
    else
        usermod -u $PUID -g $PGID root 
        for item in $(echo "$MY_DOCKER_APP_USER_ADD_GROUP" | tr ',' "$(just_get_ifs_char)"); do
            groupadd --gid $item $item
            usermod -aG $item $MY_DOCKER_APP_USER_NAME
        done
    fi
else
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
        _group_name_list=""
        for item in $(echo "$MY_DOCKER_APP_USER_ADD_GROUP_ID_LIST" | tr ',' "$(just_get_ifs_char)"); do
            item=$((10#$item))
            _group_name="$(getent group $item 2>/dev/null| awk -F':' '{print $1}')"
            if [[ -z "$_group_name" ]]; then
                _group_name=$item
            fi
            _group_name_list="${_group_name_list},${_group_name}"
        done
        _group_name_list=$(echo $_group_name_list | sed 's#,$##')
        useradd -g $MY_DOCKER_APP_USER_GROUP_NAME -G $_group_name_list -u $PUID -s $MY_DOCKER_APP_USER_SHELL -d "$MY_DOCKER_APP_USER_HOME" $MY_DOCKER_APP_USER_NAME
    else
        if [[ "$(busybox --list | grep adduser)" == "adduser" && "$(busybox --list | grep addgroup)" == "addgroup" ]]; then
            busybox addgroup -g $PGID $MY_DOCKER_APP_USER_GROUP_NAME
            busybox adduser -D -s $MY_DOCKER_APP_USER_SHELL -h "$MY_DOCKER_APP_USER_HOME" -u $PUID -G $MY_DOCKER_APP_USER_GROUP_NAME $MY_DOCKER_APP_USER_NAME
            for item in $(echo "$MY_DOCKER_APP_USER_ADD_GROUP_ID_LIST" | tr ',' ' '); do
                busybox addgroup -g $item $item
                busybox adduser $MY_DOCKER_APP_USER_NAME $item
            done
        else
            addgroup --gid $PGID $MY_DOCKER_APP_USER_GROUP_NAME
            adduser --shell $MY_DOCKER_APP_USER_SHELL --home "$MY_DOCKER_APP_USER_HOME" --uid $PUID --gid $PGID --disabled-password --no-create-home --gecos "" $MY_DOCKER_APP_USER_NAME
            for item in $(echo "$MY_DOCKER_APP_USER_ADD_GROUP_ID_LIST" | tr ',' ' '); do
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
fi
