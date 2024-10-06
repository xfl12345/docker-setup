#!/usr/bin/env bash

. /entrypoint_common_environment_setup.sh

echo "Current ID: [$(id)]"

export HOME=$MY_DOCKER_APP_USER_HOME

check_and_apply_env_if_not_found() {
    the_env_key=$1
    declare -n ref_to_var="${the_env_key}"  
    if [[ x"${ref_to_var}" == "x" ]]; then
        tmp_var="$(cat /usr/local/share/Docker/default.env | grep $the_env_key)"
        echo "ENV[${the_env_key}] is not defined. Using the default value[${tmp_var}]."
        eval "export ${tmp_var}"
    fi
}

check_and_apply_env_if_found() {
    the_env_key=$1
    declare -n ref_to_var="${the_env_key}"  
    if [[ x"${ref_to_var}" != "x" ]]; then
        echo "ENV[${the_env_key}] has been defined as [${ref_to_var}]. Writing to [/etc/environment]..."
        echo "${the_env_key}=${ref_to_var}" >> /etc/environment
    fi
}

check_and_apply_env_if_not_found "CRON_SCHEDULE"
# check_and_apply_env_if_not_found "LOG_DIR"
check_and_apply_env_if_not_found "SCRIPT_PATH"

check_and_apply_env_if_found "HTTP_PROXY"
check_and_apply_env_if_found "HTTPS_PROXY"
check_and_apply_env_if_found "ALL_PROXY"
check_and_apply_env_if_found "http_proxy"
check_and_apply_env_if_found "https_proxy"
check_and_apply_env_if_found "all_proxy"

# CRON_JOB="${CRON_SCHEDULE} ${SCRIPT_PATH} >> $LOG_DIR/local_build_image_update.log &"
CRON_JOB="${CRON_SCHEDULE} ${SCRIPT_PATH} &"
echo "CRON_JOB=${CRON_JOB}"

(crontab -u $MY_DOCKER_APP_USER_NAME -l 2>/dev/null; echo "${CRON_JOB}") | crontab -u $MY_DOCKER_APP_USER_NAME -
# (crontab -u $MY_DOCKER_APP_USER_NAME -l 2>/dev/null; echo "* * * * * /bin/date") | crontab -u $MY_DOCKER_APP_USER_NAME -
# echo "88888888 $(date)"
crond -f
# echo "88888888"
# echo "88888888 $(date)"
# while true; do
#     sleep 86400
# done
