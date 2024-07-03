#!/usr/bin/env bash
if [[ x"$(ps -a | grep -v grep | grep -oE mihomo)" == "x" ]]; then
    /mihomo &
fi
/opt/act/run.sh
