#!/usr/bin/env bash
[ -z "$PING_NET" ] && echo "ENV[PING_NET] is empty. Exiting with code 1..." && exit 1
echo "ENV[PING_NET]=$PING_NET"
fping -l -a -q -g $$PING_NET 2>/dev/null | grep -v 'timed out'
