#!/usr/bin/env bash

just_log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')][xfl_init] $1"
}

just_exec_cmd() {
    just_log "CMD: [$1]"
    eval "$1"
}

just_exec_cmd "rm /var/run/nginx/*.sock"

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
