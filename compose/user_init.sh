#!/usr/bin/env bash
my_docker_volume_dir="/media/justsave/docker/volume"

# 用户名 和 ID 映射表
declare -A my_id_map
my_id_map["www-data"]=33
my_id_map["xray"]=2001
my_id_map["metacubex"]=2002
# my_id_map["nginx"]=2003
my_id_map["jenkins"]=2004
my_id_map["qbtuser"]=2005
# 2006 reserve
# 2007 reserve
my_id_map["transmission"]=2008
my_id_map["gitea"]=2009
# gitlab user
my_id_map["gitlab"]=3001
my_id_map["gitlab-consul"]=3002
my_id_map["gitlab-mattermost"]=3003
my_id_map["gitlab-prometheus"]=3004
my_id_map["gitlab-psql"]=3005
my_id_map["gitlab-redis"]=3006
my_id_map["gitlab-registry"]=3007
my_id_map["gitlab-www"]=3008

# 目录拥有者 映射表
declare -A my_app_user_dir_map
my_app_user_dir_map["www-data:www-data"]="$my_docker_volume_dir/nginx/"
my_app_user_dir_map["www-data:www-data"]="/media/justsave/wwwroot/download/"
my_app_user_dir_map["www-data:www-data"]="/media/justsave/wwwlogs/"
# my_app_user_dir_map["nginx:nginx"]="$my_docker_volume_dir/nginx/"
my_app_user_dir_map["xray:xray"]="$my_docker_volume_dir/xray/"
my_app_user_dir_map["metacubex:metacubex"]="$my_docker_volume_dir/clash_meta/"
my_app_user_dir_map["jenkins:jenkins"]="$my_docker_volume_dir/jenkins/"
my_app_user_dir_map["gitea:gitea"]="$my_docker_volume_dir/gitea/"
my_app_user_dir_map["qbtuser:qbtuser"]="$my_docker_volume_dir/qbittorrent_nox/"
my_app_user_dir_map["qbtuser:btuser"]="/media/justsave/BT/"
my_app_user_dir_map["qbtuser:btuser"]="/media/justsave/PT/"
my_app_user_dir_map["transmission:btuser"]="$my_docker_volume_dir/transmission/"

# $1 is group name
# $2 is group id
insert_or_update_group_id() {
    if getent group $1 >/dev/null 2>&1; then
        echo "Setting Group[$1] id to [$2]..."
        groupmod -g $2 $1
    else
        echo "Adding Group[$1] with id [$2]..."
        groupadd -g $2 $1
    fi
}

insert_or_update_group_id btuser 1999
insert_or_update_group_id docker 2000

for the_user_name in "${!my_id_map[@]}"; do
    the_id=${my_id_map[$the_user_name]}
    echo "$the_user_name <---> $the_id"
    insert_or_update_group_id $the_user_name $the_id

    if id -u $the_user_name >/dev/null 2>&1; then
        usermod -g $the_id $the_user_name -s /usr/sbin/nologin
    else
        useradd -g $the_user_name -u $the_id $the_user_name -s /usr/sbin/nologin
    fi

done

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

just_add_user_to_group qbtuser btuser
just_add_user_to_group jenkins docker

for the_user_and_group in "${!my_app_user_dir_map[@]}"; do
    the_dir=${my_app_user_dir_map[$the_user_and_group]}
    the_dir=$(realpath -P "$the_dir")
    the_user_name=$(echo "$the_user_and_group" | cut -d ":" -f 1)
    the_group_name=$(echo "$the_user_and_group" | cut -d ":" -f 2)
    echo "User[$the_user_name] & Group[$the_group_name] <---> $the_dir"
    if [ -e $the_dir ]; then
        # echo "chown $the_user_and_group -Rh $the_dir"
        chown $the_user_and_group -Rh $the_dir
    else
        echo "Error: Docker volume dir[$the_dir] not found!!! Please create it first!!!"
    fi
done

mkdir -p /var/run/tailscale/
ln -s /var/run/headscale/headscale.sock /var/run/tailscale/tailscale.sock

