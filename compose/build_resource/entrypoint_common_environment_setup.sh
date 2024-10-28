#!/usr/bin/env /bash

os_release_id="$(cat /etc/os-release | grep '^ID=')"
if [[ ! -z "$os_release_id" && "$(echo $os_release_id | cut -d'=' -f2 | tr '[:upper:]' '[:lower:]')" == "alpine" ]]; then
    my_docker_env_profile="/etc/profile.d/99-my_docker_environment.sh"  
    echo "Alpine linux detected. Adding file[${my_docker_env_profile}]"
    if [ -e "$my_docker_env_profile" ]; then
        if [ -d "$my_docker_env_profile" ]; then
            rm -rf $my_docker_env_profile
        else  
            rm $$my_docker_env_profile
        fi
    fi
    echo 'if [ -f /etc/environment ]; then' > $my_docker_env_profile
    echo '    export $(grep -v '^#' /etc/environment | xargs)' >> $my_docker_env_profile
    echo 'fi' >> $my_docker_env_profile

    if [ ! -e ~/.bashrc ]; then
        echo "File [${HOME}/.bashrc] does not exist. Creating..."
        cat << EOF111 > ~/.bashrc
if [ -f /etc/profile ]; then
    . /etc/profile
fi
EOF111
    fi
fi

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
        command -v "$item" >/dev/null 2>&1
        if [[ x"$?" != "x0" ]]; then
            tmp_result="n"
            break
        fi
    done
    echo "$tmp_result"
}

mkdir -p /etc
apply_env() {
    declare -n ref_to_var="${1}"  
    echo "ENV[${1}] has been defined as [${ref_to_var}]. Writing to [/etc/environment]..."
    _env_str="${1}=${ref_to_var}"
    echo "${_env_str}" >> /etc/environment
    eval "export ${_env_str}"
}
check_and_apply_env_if_found() {
    the_env_key=$1
    declare -n ref_to_var="${the_env_key}"  
    if [[ x"${ref_to_var}" != "x" ]]; then
        apply_env "$the_env_key"
    fi
}

if [ -n "$TZ" ]; then
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
    if [[ "$(test_cmd_exist timedatectl)" == "y" ]]; then
        timedatectl set-timezone $TZ
    else
        echo "$TZ" > /etc/timezone
    fi
fi

if [[ x"$MY_DOCKER_APP_USER_NAME" == "x" && x"$PUID" == "x" ]]; then
    PUID=$(id -u)
    old_uid_username="$(id -n -u $PUID 2>/dev/null)"
    if [[ x"$old_uid_username" == "x" ]]; then
        MY_DOCKER_APP_USER_NAME="uid_$PUID"
    else
        MY_DOCKER_APP_USER_NAME="$old_uid_username"
    fi
else
    if [[ x"$MY_DOCKER_APP_USER_NAME" == "x" ]]; then
        MY_DOCKER_APP_USER_NAME="uid_${PUID}"
    else
        if [[ x"$PUID" == "x" ]]; then
            PUID=$(id -u)
        else
            PUID=$((10#$PUID))
        fi
    fi
fi

if [[ x"$PGID" == "x" ]]; then
    PGID=$(id -g)
else
    PGID=$((10#$PGID))
fi
apply_env PUID
apply_env PGID
# echo "After: PUID[$PUID] PGID[$PGID]"

if [[ x"$MY_DOCKER_APP_USER_GROUP_NAME" == "x" ]]; then
    old_groupname_id="$(getent group $MY_DOCKER_APP_USER_NAME 2>/dev/null| awk -F':' '{print $NF}')"
    if [[ x"$old_groupname_id" == "x" ]]; then
        MY_DOCKER_APP_USER_GROUP_NAME="gid_${PGID}"
    else
        MY_DOCKER_APP_USER_GROUP_NAME="$old_groupname_id"
    fi
fi
if [[ x"$MY_DOCKER_APP_USER_HOME" == "x" ]]; then
    MY_DOCKER_APP_USER_HOME="$(getent passwd $MY_DOCKER_APP_USER_NAME | cut -d: -f6)"
    if [[ x"$MY_DOCKER_APP_USER_HOME" == "x" ]]; then
        MY_DOCKER_APP_USER_HOME="/home/${MY_DOCKER_APP_USER_NAME}"
    fi
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
check_and_apply_env_if_found MY_DOCKER_APP_USER_NAME
check_and_apply_env_if_found MY_DOCKER_APP_USER_HOME
check_and_apply_env_if_found MY_DOCKER_APP_USER_SHELL
check_and_apply_env_if_found MY_DOCKER_APP_USER_GROUP_NAME
check_and_apply_env_if_found MY_DOCKER_APP_USER_ADD_GROUP_ID_LIST

check_and_apply_env_if_found "HTTP_PROXY"
check_and_apply_env_if_found "HTTPS_PROXY"
check_and_apply_env_if_found "ALL_PROXY"
check_and_apply_env_if_found "http_proxy"
check_and_apply_env_if_found "https_proxy"
check_and_apply_env_if_found "all_proxy"

gid2name() {
    _the_name="$(getent group $1 2>/dev/null| awk -F':' '{print $1}')"
    if [[ -z "$_the_name" ]];then
        _the_name="gid_$1"
    fi
    echo "$_the_name"
}

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
            _group_name="$(gid2name $item)"
            _group_name_list="${_group_name_list},${_group_name}"
        done
        _group_name_list=$(echo $_group_name_list | sed 's#,$##')
        _add_group_list_flag="-G"
        if [ -z "$_group_name_list" ]; then
            _add_group_list_flag=""
        fi
        useradd -g $MY_DOCKER_APP_USER_GROUP_NAME $_add_group_list_flag $_group_name_list -u $PUID -s $MY_DOCKER_APP_USER_SHELL -d "$MY_DOCKER_APP_USER_HOME" $MY_DOCKER_APP_USER_NAME
    else
        if [[ "$(busybox --list | grep adduser)" == "adduser" && "$(busybox --list | grep addgroup)" == "addgroup" ]]; then
            busybox addgroup -g $PGID $MY_DOCKER_APP_USER_GROUP_NAME
            busybox adduser -D -s $MY_DOCKER_APP_USER_SHELL -h "$MY_DOCKER_APP_USER_HOME" -u $PUID -G $MY_DOCKER_APP_USER_GROUP_NAME $MY_DOCKER_APP_USER_NAME
            for item in $(echo "$MY_DOCKER_APP_USER_ADD_GROUP_ID_LIST" | tr ',' ' '); do
                _group_name="$(gid2name $item)"
                busybox addgroup -g $item $_group_name
                busybox adduser $MY_DOCKER_APP_USER_NAME $_group_name
            done
        else
            addgroup --gid $PGID $MY_DOCKER_APP_USER_GROUP_NAME
            adduser --shell $MY_DOCKER_APP_USER_SHELL --home "$MY_DOCKER_APP_USER_HOME" --uid $PUID --gid $PGID --disabled-password --no-create-home --gecos "" $MY_DOCKER_APP_USER_NAME
            for item in $(echo "$MY_DOCKER_APP_USER_ADD_GROUP_ID_LIST" | tr ',' ' '); do
                _group_name="$(gid2name $item)"
                addgroup --gid $item $_group_name
                adduser $MY_DOCKER_APP_USER_NAME $_group_name
            done
        fi
    fi

    # 为了兼容 link 目录，当且仅当两者均判断为否时，才创建文件夹
    if [ ! -d "$MY_DOCKER_APP_USER_HOME" -a ! -f "$MY_DOCKER_APP_USER_HOME" ]; then
        mkdir -p "$MY_DOCKER_APP_USER_HOME"
    fi
    chown $MY_DOCKER_APP_USER_NAME:$MY_DOCKER_APP_USER_GROUP_NAME -Rh "$MY_DOCKER_APP_USER_HOME"
fi
