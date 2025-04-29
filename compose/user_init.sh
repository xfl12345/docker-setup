#!/usr/bin/env bash
my_docker_volume_dir="/mnt/justsave/docker/volume"
the_realpath_feature_flag="-P"
my_file_name="$(basename "$0")"

just_log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')][${my_file_name}] ${1}"
}

exec_cmd() {
    local __tmp_cmd="$1"
    just_log "CMD[$__tmp_cmd]"
    eval "$__tmp_cmd"
}

if [[ x"$(realpath --help | grep -w '\-\-canonicalize\-missing')" != "x" ]]; then
    just_log "[$(which realpath)] support '--canonicalize-missing'"
    the_realpath_feature_flag="-Pm"
fi

if [ ! -e /mnt/justsave/docker/compose/global_default.env ]; then
    if [[ "$(date +%z 2>/dev/null)" == "+0800" ]]; then
        bash -c "cd /mnt/justsave/docker/compose && ln -s global_defaul{t.example,t}.env"
        just_log "Created a global default env file as a symbolic link. Checking..."
        ls -lah /mnt/justsave/docker/compose/global_default.env
    else
        bash -c "cd /mnt/justsave/docker/compose && cp global_defaul{t.example,t}.env"
        just_log "Created global default env file. Checking..."
        ls -lah /mnt/justsave/docker/compose/global_default.env
    fi
fi

# 用户名 和 ID 映射表
declare -A my_id_map
my_id_map["www-data"]=33
# 2001 reserve
my_id_map["metacubex"]=2002
# my_id_map["nginx"]=2003
my_id_map["jenkins"]=2004
my_id_map["qbtuser"]=2005
my_id_map["code-server"]=2006
my_id_map["peerbanhelper"]=2007
my_id_map["transmission"]=2008
my_id_map["gitea"]=2009
my_id_map["libreoffice"]=2010
# gitlab user
my_id_map["gitlab"]=3001
my_id_map["gitlab-consul"]=3002
my_id_map["gitlab-mattermost"]=3003
my_id_map["gitlab-prometheus"]=3004
my_id_map["gitlab-psql"]=3005
my_id_map["gitlab-redis"]=3006
my_id_map["gitlab-registry"]=3007
my_id_map["gitlab-www"]=3008

# $1 is group name
# $2 is group id
insert_or_update_group_id() {
    if getent group $1 >/dev/null 2>&1; then
        just_log "Setting Group[$1] id to [$2]..."
        groupmod -g $2 $1
    else
        just_log "Adding Group[$1] with id [$2]..."
        groupadd -g $2 $1
    fi
}

insert_or_update_group_id btuser 1999
insert_or_update_group_id docker 2000

for the_user_name in "${!my_id_map[@]}"; do
    the_id=${my_id_map[$the_user_name]}
    insert_or_update_group_id $the_user_name $the_id

    if id -u $the_user_name >/dev/null 2>&1; then
        usermod -g $the_id $the_user_name -s /usr/sbin/nologin
    else
        useradd -g $the_user_name -u $the_id $the_user_name -s /usr/sbin/nologin
    fi

done

# $1 is user name
# $2 is group name
just_set_user_main_group() {
    _user_name="$1"
    _new_group="$2"
    _current_primary="$(id -gn "$_user_name")"

    # 获取当前用户的所有附加组
    _other_groups="$(id -Gn "$_user_name" | tr ' ' '\n' | grep -v "$_current_primary" | grep -v "$_new_group" | tr '\n' ',' | sed 's#,$##')"
    # 将当前用户的主组添加到附加组列表中
    if [[ -z "$_other_groups" ]]; then
        _other_groups="$_current_primary"
    else
        _other_groups="${_other_groups},${_current_primary}"
    fi

    exec_cmd "usermod -g $_new_group -aG $_other_groups $_user_name"
    just_log "$(id $_user_name)"
}

# $1 is user name
# $2 is group name
just_add_user_to_group() {
    if [ "`groups $1 | grep -w "$2"`" = "" ]; then
        gpasswd -a $1 $2
        echo "User[$1] has been appended to Group[$2]."
    else
        echo "User[$1] in Group[$2] already!"
    fi
}

just_set_user_main_group qbtuser btuser
just_set_user_main_group transmission btuser
just_add_user_to_group jenkins docker
just_add_user_to_group gitea docker

__the_path=""
get_real_path() {
    __the_path=$(realpath $the_realpath_feature_flag $1 2>&1)
    if [ $? -ne 0 ]; then
        __the_path=$(echo $__the_path | sed -n 's#^realpath: \([^:]*\): No such file or directory$#\1#p')
    fi
}

just_chown() {
    the_user_and_group=$1
    the_dir=$2
    get_real_path "$the_dir"
    the_dir=$__the_path
    the_user_name=$(echo "$the_user_and_group" | cut -d ":" -f 1)
    the_group_name=$(echo "$the_user_and_group" | cut -d ":" -f 2)
    echo "User[$the_user_name] & Group[$the_group_name] <---> $the_dir"
    if [ -e $the_dir ]; then
        # echo "chown $the_user_and_group -Rh $the_dir"
        chown $the_user_and_group -Rh $the_dir
    else
        echo "Warming: Docker volume dir[$the_dir] was not found!!! Skipped."
    fi
}

just_chown "www-data:www-data" "$my_docker_volume_dir/nginx/moved_root/"
just_chown "metacubex:metacubex" "$my_docker_volume_dir/clash_meta/"
just_chown "jenkins:jenkins" "$my_docker_volume_dir/jenkins/"
just_chown "gitea:gitea" "$my_docker_volume_dir/gitea/"
just_chown "libreoffice:libreoffice" "$my_docker_volume_dir/libreoffice/"
just_chown "qbtuser:qbtuser" "$my_docker_volume_dir/qbittorrent_nox/"
just_chown "qbtuser:btuser" "/mnt/justsave/BT/"
just_chown "qbtuser:btuser" "/mnt/justsave/PT/"
just_chown "transmission:btuser" "$my_docker_volume_dir/transmission/"
just_chown "code-server:code-server" "$my_docker_volume_dir/code_server/home/"
just_chown "peerbanhelper:peerbanhelper" "$my_docker_volume_dir/peer_ban_helper/app/"

docker_setup_app_dir_path="/mnt/justsave/docker/compose/standalone/docker_setup"
docker_setup_app_compose_file_path="${docker_setup_app_dir_path}/docker-compose.yml"
if [ ! -e $docker_setup_app_compose_file_path ]; then
    docker_setup_app_compose_file_path="${docker_setup_app_dir_path}/docker-compose.example.yml"
fi

export SCRIPT_PATH="/app/user_init.sh"
docker compose -f $docker_setup_app_compose_file_path up
docker compose -f $docker_setup_app_compose_file_path rm -f docker_setup
