#!/usr/bin/env bash
ex="example"
pv="private"
base_path="/etc/nginx/snippets"

# file_list="$(cat /usr/local/share/xfl/check_file_list.txt | grep -v '^$')"
file_list="$(cd $base_path/$ex && grep -r --include="*.conf" "include snippets/private" . | sed '/\*\.conf/d' | cut -d':' -f1 | sort | uniq)"

just_log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')][xfl_init] $1"
}

for rel_path in $file_list; do
    curr_example_file_path="$(realpath -Pm ${base_path}/${ex}/${rel_path})"
    curr_private_file_path="$(realpath -Pm ${base_path}/${pv}/${rel_path})"
    if [ ! -e $curr_private_file_path -a -e $curr_example_file_path  ]; then
        file_content="include ${curr_example_file_path};"
        just_log "Generating file[${curr_private_file_path}] with content[${file_content}]..."
        just_log "${file_content}" >> $curr_private_file_path
    fi
done

just_log "All done!"
