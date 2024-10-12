#!/usr/bin/env bash

. /entrypoint_common_environment_setup.sh

echo "Current ID: [$(id)]"

export HOME=$MY_DOCKER_APP_USER_HOME
rm $HOME/data/certificates
cd "$HOME"
echo "CMD: [su $MY_DOCKER_APP_USER_NAME -c \"/entrypoint.sh $@\"]"
su $MY_DOCKER_APP_USER_NAME -c "/entrypoint.sh $@"
