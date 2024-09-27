#!/usr/bin/env bash

the_origin_pwd=$(pwd)
the_container_list=$(docker ps --filter "label=cc.xfl12345.code.share.docker.setup.localbuild=true" --format "{{.Names}}")
# the_container_list="$(echo $the_container_list)"
declare -A the_project_list
declare -A the_project_config_files_list
declare -A the_mission_state

get_date() {
    echo $(date '+%Y-%m-%d %H:%M:%S')
}

just_log() {
    echo "[$(get_date)] $1"
}

just_exec_cmd() {
    the_cmd=$1
    just_log "CMD:[${the_cmd}]"
    $1
}

# yaml_tool_docker_tag='mikefarah/yq:latest'
# tmp_var="$(docker image inspect $yaml_tool_docker_tag 2>/dev/null)"
# if [[ "$tmp_var" == "[]" ]]; then
#     just_log "The docker image [$yaml_tool_docker_tag] is not found. Pulling..."
#     docker pull $yaml_tool_docker_tag
#     the_return_code=$?
#     if [ $the_return_code -eq 0 ]; then
#         just_log "The docker image [$yaml_tool_docker_tag] was successfully pulled."
#     else
#         just_log "Failed to pull docker image [$yaml_tool_docker_tag]. Mission cancled."
#         exit $the_return_code
#     fi
# else
#     just_log "The docker image [$yaml_tool_docker_tag] is found. Extracting..."
#     container_id=$(docker create $yaml_tool_docker_tag)
#     docker cp $container_id:/usr/bin/yq ./
# fi

for item in $the_container_list; do
    just_log "Checking APP [$item]"
    container_is_running=$(docker inspect --format '{{.State.Running}}' "$item")
    if [[ "${container_is_running}" == "true" ]]; then
        docker_project_name=$(docker inspect --format '{{index .Config.Labels "com.docker.compose.project"}}' "$item")
        docker_project_config_files=$(docker inspect --format '{{index .Config.Labels "com.docker.compose.project.config_files"}}' "$item")
        docker_working_dir=$(docker inspect --format '{{index .Config.Labels "com.docker.compose.project.working_dir"}}' "$item")
        if [[ x"${the_project_list[$docker_project_name]}" == "x" ]]; then
            the_project_list[$docker_project_name]=$docker_working_dir
        elif [[ "${the_project_list[$docker_project_name]}/docker-compose.yml" != "${docker_project_config_files}" ]]; then
            docker_service_name=$(docker inspect --format '{{index .Config.Labels "com.docker.compose.service"}}' "$item")
            the_key="${docker_project_name}_${docker_service_name}"
            the_project_list[$the_key]="${docker_working_dir}"
            the_project_config_files_list[$the_key]="${docker_project_config_files}"
        fi
    else
        just_log "APP [$item] is not running. Skipped."
    fi
done

for item in "${!the_project_list[@]}"; do
    the_container_working_dir="${the_project_list[$item]}"
    just_log "Building [${item}] in [${the_container_working_dir}]..."
    the_extra_config_params=""
    if [[ x"${the_project_config_files_list[$item]}" != "x" ]]; then
        the_extra_config_params="-f "$(echo $project_config_files | tr ',' ' ' | sed 's# # -f #g')
    fi

    the_mission_state["${item}"]="Failed"
    just_exec_cmd "cd $the_container_working_dir"
    if [ $? -ne 0 ]; then
        just_log "Failed. Skipped."
        continue
    fi
    # just_exec_cmd "docker compose config | yq '.services..build.dockerfile'"
    just_exec_cmd "docker compose build ${the_extra_config_params} --pull"
    if [ $? -ne 0 ]; then
        just_log "Failed. Skipped."
        continue
    fi
    just_exec_cmd "docker compose up ${the_extra_config_params} -d --remove-orphans"
    if [ $? -ne 0 ]; then
        just_log "Failed. Skipped."
        continue
    fi
    the_mission_state["${item}"]="Succeed"
    just_log "Done."
done

just_log "Mission Summary"
for item in "${!the_mission_state[@]}"; do
    just_log "[${item}] <---> [${the_mission_state[$item]}]"
done

just_log "All Done."
