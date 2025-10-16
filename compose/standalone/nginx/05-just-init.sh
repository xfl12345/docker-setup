#!/usr/bin/env bash
set -e

just_log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')][fdn_init] $1"
}

just_exec_cmd() {
    just_log "CMD: [$1]"
    eval "$1"
}

just_exec_cmd "find /var/run/nginx -maxdepth 1 -name '*.sock' -delete"
just_exec_cmd "chown www-data:www-data -R /var/log/nginx/"

if [ ! -e /usr/share/nginx/html ]; then
    just_log "dir[/usr/share/nginx/html] is not found. Will create it..."
    just_exec_cmd "mkdir -p /usr/share/nginx/html"
    just_log "dir[/usr/share/nginx/html] is created."
fi

latest_example_snippets_version="$(cat /etc/nginx/snippets/example/by_version/latest_version)"
latest_example_snippets_directory="/etc/nginx/snippets/example/by_version/${latest_example_snippets_version}"
user_current_snippets_directory="/etc/nginx/snippets/private/by_version/current"

just_log "Current ID[$(id)] latest_example_snippets_version[${latest_example_snippets_version}]"

if [ ! -e $user_current_snippets_directory ]; then
    just_log "file[$user_current_snippets_directory] is not found. Will create it..."
    user_versioned_snippets_directory="/etc/nginx/snippets/private/by_version/${latest_example_snippets_version}"
    mkdir -p "${user_versioned_snippets_directory}"
    just_exec_cmd "ln -s ${latest_example_snippets_version} $user_current_snippets_directory"
    if [ ! -e "${user_versioned_snippets_directory}/nginx.conf" ]; then
        just_log "file[${user_versioned_snippets_directory}/nginx.conf] is not found. Will create it..."
        echo -e "include snippets/example/by_version/${latest_example_snippets_version}/nginx.conf;\n" > "${user_versioned_snippets_directory}/nginx.conf"
        just_log "file[${user_versioned_snippets_directory}/nginx.conf] is created."
    fi
fi

user_current_version="$(basename $(readlink $user_current_snippets_directory))"
current_user_config_directory="/etc/nginx/snippets/private/by_version/current/config"
current_example_config_directory="/etc/nginx/snippets/example/by_version/${user_current_version}/config"
mixins_config_directory="/etc/nginx/snippets/config/by_version/${user_current_version}"
just_exec_cmd "mkdir -p $mixins_config_directory"
just_exec_cmd "cp -rvp $current_example_config_directory/* $mixins_config_directory"
if [ -e $current_user_config_directory ]; then
    just_exec_cmd "cp -rvp $current_user_config_directory/* $mixins_config_directory"
fi

# snippets/example/by_version/v3/example_config

if [ ! -e /etc/ssl/dhparam/dhe4096.pem ]; then
    just_log "file[/etc/ssl/dhparam/dhe4096.pem] is not found. Generating..."
    openssl dhparam -out /etc/ssl/dhparam/dhe4096.pem 4096
    just_log "file[/etc/ssl/dhparam/dhe4096.pem] is generated."
fi

# if [ ! -e /etc/nginx/geoip/geoip.mmdb ]; then
#     just_log "file[/etc/nginx/geoip/geoip.mmdb] is not found. Will use the default one..."
#     cp /etc/nginx/geoip/example/geoip.mmdb /etc/nginx/geoip/geoip.mmdb
# fi

just_log "All done!"
