#!/usr/bin/env bash
. /entrypoint_common_environment_setup.sh

chown $MY_DOCKER_APP_USER_NAME:$MY_DOCKER_APP_USER_GROUP_NAME -Rh /var/run/ttyd
echo "CMD: [su $MY_DOCKER_APP_USER_NAME -c \"ttyd $TTYD_OPT\"]"
# su -s /bin/bash ttyd -c "\"$@\""
# exec doas -u ttyd ttyd $TTYD_OPT
# exec doas -u ttyd "ping qq.com"
# su ttyd -c "$@"
# ping qq.com
export HOME=$MY_DOCKER_APP_USER_HOME
cd "$HOME"
su $MY_DOCKER_APP_USER_NAME -c "ttyd $TTYD_OPT"
