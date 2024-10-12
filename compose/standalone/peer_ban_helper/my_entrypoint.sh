#!/usr/bin/env bash

. /entrypoint_common_environment_setup.sh

origin_entrypoint=$(cat /origin-entrypoint.txt)

export HOME=$MY_DOCKER_APP_USER_HOME
cd "$HOME"
# echo "PWD:[$(pwd)], ID:[$(id)]"
# ls -lah
echo "CMD: [su $MY_DOCKER_APP_USER_NAME -c \"$origin_entrypoint $@\"]"
su $MY_DOCKER_APP_USER_NAME -c "$origin_entrypoint $@"
