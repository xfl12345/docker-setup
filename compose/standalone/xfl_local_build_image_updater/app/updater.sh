#!/usr/bin/env bash
cd "$(dirname "$(readlink -f "$0")")"
. ./myvenv/bin/activate
./updater.py
