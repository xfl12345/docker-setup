#!/usr/bin/env bash
. /entrypoint_common_environment_setup.sh
export HOME=$MY_DOCKER_APP_USER_HOME
cd $HOME
su $MY_DOCKER_APP_USER_NAME -c "/usr/local/bin/jenkins.sh"
