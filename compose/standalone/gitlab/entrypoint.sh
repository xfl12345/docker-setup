#!/usr/bin/env bash
service sendmail restart &
service cron restart
exec /assets/wrapper
