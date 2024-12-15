#!/usr/bin/env bash
my_file_name="$(basename "$0")"

just_log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')][${my_file_name}] ${1}"
}

run_hook() {
    __script_file_path=$1
    if [ -f $__script_file_path -a -r $__script_file_path ]; then
        just_log "[$__script_file_path] Found. Executing..."
        source $__script_file_path
        just_log "[$__script_file_path] Done."
    else
        local __tmp_cmd="ls -lah ${__script_file_path}"
        just_log "CMD[${__tmp_cmd}]"
        eval $__tmp_cmd
        if [ -d $__script_file_path ]; then
            just_log "[$__script_file_path] is a directory. Skip."
        elif [ -f $__script_file_path ]; then
            just_log "[$__script_file_path] is a file but not readable. Skip."
        else
            just_log "[$__script_file_path] do not exist. Skip."
        fi
    fi
}

run_hook "/entrypoint-before-up.sh"

wg-quick up wg0 || exit $?

run_hook "/entrypoint-after-up.sh"

while true; do
    # 前面表达式执行失败的时候 break
    sleep 999999 || break
done

wg-quick down wg0
