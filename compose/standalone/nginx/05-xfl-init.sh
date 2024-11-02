#!/usr/bin/env bash
ex="example"
pv="private"

# file_list="$(cat /usr/local/share/xfl/check_file_list.txt | grep -v '^$')"
raw_file_list="$(grep -r --include="*.conf" "include snippets/private" /etc/nginx/snippets/$px /etc/nginx/snippets/$ex /etc/nginx/nginx.conf | grep -v "conf:#")"
generate_file_list="$(echo -e "$raw_file_list" | grep -v '*.conf;' | grep -oE 'include .*$' | sed 's#;$##' | cut -d' ' -f2 | sort | uniq)"
mkdir_list="$(echo -e "$raw_file_list" | grep '*.conf;' | grep -oE 'include .*$' | sed 's#include ##g' | sed 's#\*\.conf;##g' | cut -d':' -f2 | sort | uniq)"

just_log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')][xfl_init] $1"
}

just_exec_cmd() {
    just_log "CMD: [$1]"
    eval "$1"
}

just_log "Current ID[$(id)]"

for rel_path in $mkdir_list; do
    curr_private_dir_path="$(realpath -Pm /etc/nginx/${rel_path})"
    just_log "Checking dir[${curr_private_dir_path}]..."
    if [ ! -e $curr_private_dir_path ]; then
        just_exec_cmd "mkdir -p $curr_private_dir_path"
    fi
done

for rel_path in $generate_file_list; do
    curr_private_file_path="$(realpath -Pm /etc/nginx/$rel_path)"
    curr_example_file_path="$(echo $curr_private_file_path | sed 's#^/etc/nginx/snippets/private#/etc/nginx/snippets/example#')"
    just_log "Checking file[${curr_example_file_path}]..."
    if [ ! -e $curr_private_file_path ]; then
        if [ -e $curr_example_file_path ]; then
            just_log "Example file[${curr_example_file_path}] was found."
            file_content="include $(echo $curr_example_file_path | sed 's#^/etc/nginx/##');"
        else
            just_log "Example file[${curr_example_file_path}] was NOT found."
            file_content=""
        fi
        just_exec_cmd "mkdir -p $(dirname $curr_private_file_path 2>/dev/null)"
        just_exec_cmd "echo -e \"${file_content}\" >> $curr_private_file_path"
    fi
done

if [ ! -e /etc/ssl/dhparam/dhe4096.pem ]; then
    openssl dhparam -out /etc/ssl/dhparam/dhe4096.pem 4096
fi

just_log "All done!"
