#/usr/bin/env bash
docker compose run --rm --pull=never --name=tmp-test-nginx --entrypoint='/usr/bin/bash -c' nginx '/docker-entrypoint.d/05-just-init.sh && nginx -t'
if [ $? -eq 0 ]; then
  echo "Nginx configuration is valid"
else
  echo "Nginx configuration is invalid"
  exit 1
fi
