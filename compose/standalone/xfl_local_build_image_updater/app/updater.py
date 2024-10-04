#!/usr/bin/env python3
import os
import re
import time
from pathlib import Path 
from collections import OrderedDict
import docker
from loguru import logger
from python_on_whales import docker as docker_cli
from python_on_whales.exceptions import DockerException

origin_working_dir = os.getcwd()
# 连接到 Docker 守护进程
client = docker.from_env()

label_filter = {"label": "cc.xfl12345.code.share.docker.setup.localbuild=true"}

# 获取所有容器（不包括未运行的）
containers = client.containers.list(all=False, filters=label_filter)

the_project_map = {}
the_project_config_files_map = {}

# 打印找到的容器ID和名称
for container in containers:
    logger.info(f"Container ID: {container.id}, Name: {container.name}")
    container_inspect_data = client.api.inspect_container(container.id)
    labels = container_inspect_data["Config"]["Labels"]
    docker_project_name = labels["com.docker.compose.project"]
    docker_project_config_files = labels["com.docker.compose.project.config_files"]
    docker_project_working_dir = labels["com.docker.compose.project.working_dir"]
    if docker_project_config_files == docker_project_working_dir + "/docker-compose.yml":
        the_project_map[docker_project_name] = docker_project_working_dir
    else:
        the_key = docker_project_name + '_' + labels["com.docker.compose.service"]
        the_project_map[the_key] = docker_project_working_dir
        the_project_config_files_map[the_key] = docker_project_config_files.split(',')

def fetch_service_build_context(root: dict) -> list:
    result = []
    if "services" in root:
        for service, service_body in root["services"].items():
            if "build" in service_body:
                result.append( service_body["build"])
    return result

not_supported_docker_build_context_prefixs = ("http://", "https://", "git://", "git+https://", "git+http://", "git+ssh://")
cache_os_path_seprator = os.path.sep
def get_docker_compose_dockerfile_path(docker_build_context: dict, current_working_dir: str) -> str:
    result = ""
    v_dockerfile: str = docker_build_context.get("dockerfile")
    v_context: str = docker_build_context["context"]
    if not v_context.lower().startswith(not_supported_docker_build_context_prefixs):
        # resolve local file only
        if v_context.startswith(cache_os_path_seprator) or v_context.startswith('.' + cache_os_path_seprator):
            the_path = Path(current_working_dir).joinpath(os.path.join(v_context, v_dockerfile)).resolve()
            if os.path.exists(the_path):
                result = the_path
    return result


def append_docker_image_tags(line:str, tags:list):
    line = line.rstrip()
    if line.startswith("FROM"):
        tag = ""
        meet_index = 0
        for item in line.split(' '):
            if item == "":
                continue
            match meet_index:
                case 0:
                    if item.upper() == "FROM":
                        meet_index += 1
                case 1:
                    tag += item
                    meet_index += 1
                    break
                # case 2:
                #     tag += item
                #     meet_index += 1
        if tag != "":
            tags.append(tag)


status_map = OrderedDict()
for item_name, the_container_working_dir in the_project_map.items():
    logger.info(f"Building [{item_name}] in [{the_container_working_dir}]...")
    config_files = the_project_config_files_map.get(item_name)
    images = []
    if config_files is None:
        docker_project_working_dir = the_project_map[item_name]
        try:
            config_file_path = Path(docker_project_working_dir + "/docker-compose.yml").resolve()
        except FileNotFoundError as e:
            logger.warning(f"File is not found. Error message:\n{e}")
            continue
        os.chdir(docker_project_working_dir)
        docker_compose_config = docker_cli.compose.config(config_file_path)
        build_config_list = fetch_service_build_context(docker_compose_config)
        docker_image_tag_list = []
        for build_config in build_config_list:
            if "dockerfile_inline" in build_config:
                for line in build_config["dockerfile_inline"].split('\n'):
                    append_docker_image_tags(line, docker_image_tag_list)
            else:
                docker_compose_dockerfile_path = get_docker_compose_dockerfile_path(build_config, docker_project_working_dir)
                if docker_compose_dockerfile_path != "" :
                    with open(docker_compose_dockerfile_path) as file:
                        for line in file:
                            append_docker_image_tags(line, docker_image_tag_list)
        last_time = 0
        success = False
        for retry_count in range(3):
            start_time = time.time()
            try:
                for tag in docker_image_tag_list:
                    docker_cli.pull(tag)
                docker_cli.compose.up(detach=True, remove_orphans=True)
                end_time = time.time()
                last_time += end_time - start_time
                success = True
                break
            except DockerException as e:
                end_time = time.time()
                last_time += end_time - start_time
                time.sleep(30)
        status_map[item_name] = {
            "retry_count": retry_count,
            "last_time": last_time,
            "success": success
        }
    else:
        logger.warning("Not support for docker compose with multiple configuration files.")

for item_name, status in status_map.items():
    logger.info("; ".join([
            f"Item[{item_name}]",
            f"Status[{"success" if status["success"] else "fail"}]",
            f"Retry count[{status["retry_count"]}]",
            f"Last for [{status["last_time"]:.3f}] seconds"
        ]))

logger.info("All done.")
