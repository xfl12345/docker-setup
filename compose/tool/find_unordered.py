#!/usr/bin/env python3
from collections import OrderedDict
import os
import io
import json
import subprocess
from datetime import datetime
import sys
import docker
from loguru import logger
from docker.models.containers import Container
from python_on_whales import DockerClient, docker as docker_cli
from python_on_whales.exceptions import DockerException
from ruamel.yaml import YAML
from ruamel.yaml.comments import CommentedMap
from tzlocal import get_localzone

the_service_key_order = [
    "env_file",
    "extends",
    "labels",
    "user",
    "pid",
    "ipc",
    "privileged",
    "cap_add",
    "sysctls",
    "security_opt",
    "tty",
    "shm_size",
    "image",
    "container_name",
    "pull_policy",
    "build",
    "devices",
    "tmpfs",
    "volumes",
    "entrypoint",
    "command",
    "healthcheck",
    "logging",
    "hostname",
    "extra_hosts",
    "links",
    "networks",
    "network_mode",
    "ports",
    "depends_on",
    "stop_grace_period",
    "restart"
]

def main():
    program_start_time = datetime.now(tz=get_localzone())
    origin_workdir = os.getcwd()
    year_month_day = program_start_time.strftime("%Y-%m-%d")
    logger.add(f"./logs/{year_month_day}.log", level="TRACE", buffering=1, encoding="utf8")

    yaml = YAML()
    yaml.indent(mapping=2, sequence=4, offset=2)
    yaml.representer.add_representer(OrderedDict, lambda dumper, data: dumper.represent_dict(data))

    the_len_of_service_key_order = len(the_service_key_order)

    for root, dirs, files in os.walk("/mnt/justsave/docker/compose/standalone"):
        if 'docker-compose.yaml' not in files:
            continue
        curr_app_dir = root
        curr_app_file = os.path.join(curr_app_dir, "docker-compose.yaml")
        with open(curr_app_file, 'r') as f:
            # logger.info(f"Processing {curr_app_file}")
            data_root = yaml.load(f)
            if data_root is not None:
                service_names = list(data_root["services"].keys())
                is_ok = True
                for service_name in service_names:
                    service_keys = list(data_root["services"][service_name].keys())
                    current_index = 0
                    for key in service_keys:
                        inserted = False
                        if current_index < the_len_of_service_key_order:
                            the_rest = the_service_key_order[current_index:]
                            for index, item in enumerate(the_rest):
                                if key == item:
                                    inserted = True
                                    break
                                current_index += 1
                        if not inserted:
                            logger.warning(f"Unordered service[{service_name}][{key}] in file: {curr_app_file}")
                            break

                if is_ok:
                    logger.success(f"Ordered file: {curr_app_file}")

if __name__ == "__main__":
    main()