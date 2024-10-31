#!/bin/sh
rm -f /var/run/xray/*.sock
/usr/bin/xray -config /etc/xray/config.json
