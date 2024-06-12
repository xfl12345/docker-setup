#!/bin/bash

if [ -n "$TZ" ]; then
  ln -snf /usr/share/zoneinfo/$TZ /etc/localtime
  echo $TZ > /etc/timezone
fi

# echo "Before: PUID[$PUID] PGID[$PGID]"

if [[ x"$PUID" == "x" ]]; then
    PUID=1000
fi
if [[ x"$PGID" == "x" ]]; then
    PGID=1000
fi

# echo "After: PUID[$PUID] PGID[$PGID]"

sed -i "/:x:$PUID:$PUID:/d" /etc/passwd
sed -i "/:x:$PGID:/d" /etc/group
# sed -i "/ttyd:x:/d" /etc/passwd
# sed -i "/:x:$PGID:/d" /etc/group

if [[ x"$(cat /etc/passwd | grep ttyd)" == "x" ]]; then
    delgroup ttyd
    adduser -D -s /bin/bash -h /home/ttyd -u $PUID ttyd
else
    sed -i "s|^ttyd:x:[0-9]*:|ttyd:x:$PUID:|g" /etc/passwd
    sed -i "s|^\(ttyd:x:[0-9]*\):[0-9]*:|\1:$PGID:|g" /etc/passwd
    sed -i "s|^ttyd:x:[0-9]*:|ttyd:x:$PGID:|g" /etc/group
fi

# echo -e "cat [/etc/passwd]\n$(cat /etc/passwd)"
# echo -e "cat [/etc/group]\n$(cat /etc/group)"

chown ttyd:ttyd -Rh /home/ttyd
chown ttyd:ttyd -Rh /var/run/ttyd
echo "CMD: [ttyd $TTYD_OPT]"
# su -s /bin/bash ttyd -c "\"$@\""
exec doas -u ttyd ttyd $TTYD_OPT
# exec doas -u ttyd "ping qq.com"
# su ttyd -c "$@"
# ping qq.com
