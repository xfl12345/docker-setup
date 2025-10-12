#!/usr/bin/env bash

just_log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')][xfl_init] $1"
}

just_exec_cmd() {
    just_log "CMD: [$1]"
    eval "$1"
}

just_exec_cmd "rm /var/run/nginx/*.sock"

latest_example_snippets_version="$(cat /etc/nginx/snippets/example/by_version/latest_version)"
just_log "Current ID[$(id)] latest_example_snippets_version[${latest_example_snippets_version}]"

if [ ! -e /etc/nginx/snippets/private/current ]; then
    just_log "file[/etc/nginx/snippets/private/current] is not found. Will create it..."
    just_exec_cmd "ln -s /etc/nginx/snippets/private/${latest_example_snippets_version} /etc/nginx/snippets/private/current"
fi

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
