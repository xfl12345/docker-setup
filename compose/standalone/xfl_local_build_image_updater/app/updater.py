#!/usr/bin/env python3
import os
import re
import time
import json
from pathlib import Path
from collections import OrderedDict
from datetime import datetime
from loguru import logger
import docker
from docker.models.containers import Container
from python_on_whales import docker as docker_cli
from python_on_whales.exceptions import DockerException
from tzlocal import get_localzone

program_start_time = datetime.now(tz=get_localzone())
year_month_day = program_start_time.strftime("%Y-%m-%d")
logger.add(f"./logs/{year_month_day}.log", level="TRACE", buffering=1, encoding="utf8")

# 筛选标签
label_filter = {"label": "cc.xfl12345.code.share.docker.setup.localbuild=true"}
# 备份原初工作目录
origin_working_dir = os.getcwd()
# 获取系统路径分隔符
cache_os_path_seprator = os.path.sep
# not_supported_docker_build_context_prefixs = ("http://", "https://", "git://", "git+https://", "git+http://", "git+ssh://")

# 连接到 Docker 守护进程
client = docker.from_env()
# 获取所有目标容器（不包括未运行的）
containers: list[Container] = client.containers.list(
    all=False,
    filters=label_filter
)


class TaskStatus:
    def __init__(self, container: Container, retry_count: int, last_time: float, success: bool):
        self.container = container
        self.retry_count = retry_count
        self.last_time = last_time
        self.success = success

    def to_dict_without_container_field(self):
        return {
            "retry_count": self.retry_count,
            "last_time": self.last_time,
            "success": self.success
        }


# 容器镜像更新任务状态表
task_status_map: dict[str, OrderedDict[str, TaskStatus]] = {
    "build": OrderedDict(),
    "up": OrderedDict(),
    "summary": OrderedDict()
}


def task_exec(status_map: OrderedDict[str, TaskStatus], container: Container, hook: callable):
    last_time = 0
    success = False
    for retry_count in range(3):
        start_time = time.time()
        try:
            # 执行任务
            hook(container.labels["com.docker.compose.service"])
            end_time = time.time()
            last_time += end_time - start_time
            success = True
            break
        except DockerException as e:
            end_time = time.time()
            last_time += end_time - start_time
            logger.error(e)
            logger.warning("retrying in 5 seconds...")
            time.sleep(5)

    status_map[container.id] = TaskStatus(
        container=container,
        retry_count=retry_count,
        last_time=last_time,
        success=success
    )


def task_unit_docker_compose_build(docker_project_service_name: str):
    # # Docker 构建环境额外参数
    # build_args = {
    #     "HTTP_PROXY": os.getenv("HTTP_PROXY"),
    #     "HTTPS_PROXY": os.getenv("HTTPS_PROXY"),
    #     "NO_PROXY": os.getenv("NO_PROXY")
    # }
    # for key, value in build_args.items():
    #     if value is None:
    #         del build_args[key]
    # if len(build_args) == 0:
    #     build_args = None

    docker_cli.compose.build(
        services=[docker_project_service_name]
        # pull=True,
        # build_args=build_args
    )


def task_unit_docker_compose_up(docker_project_service_name: str):
    docker_cli.compose.up(
        services=[docker_project_service_name],
        # remove_orphans=True,
        detach=True
    )


# 执行容器更新
for container in containers:
    # 打印找到的容器ID和名称
    logger.info(f"Name: {container.name}, Container ID: {container.id}")
    container_inspect_data = client.api.inspect_container(container.id)
    container_config = container_inspect_data["Config"]
    container_labels = container_config["Labels"]
    docker_project_name = container_labels["com.docker.compose.project"]
    docker_project_config_files = container_labels["com.docker.compose.project.config_files"]
    docker_project_working_dir = container_labels["com.docker.compose.project.working_dir"]
    if docker_project_config_files == docker_project_working_dir + "/docker-compose.yml":
        try:
            config_file_path = Path(docker_project_config_files).resolve()
        except FileNotFoundError as e:
            logger.warning(f"File is not found. Skip. Error message:\n{e}")
            continue
    else:
        logger.warning("Not support for docker compose with multiple configuration files.")
        continue

    docker_project_service_name = container_labels["com.docker.compose.service"]
    logger.info(f"Building [{docker_project_service_name}] in [{docker_project_working_dir}]...")
    os.chdir(docker_project_working_dir)
    task_exec(
        status_map=task_status_map["build"],
        container=container,
        hook=task_unit_docker_compose_build
    )

    build_status = task_status_map["build"][container.id]
    if not build_status.success:
        logger.error(f"Build [{docker_project_service_name}] failed.")
        up_status = TaskStatus(
            container=container,
            retry_count=0,
            last_time=0,
            success=False
        )
        task_status_map["up"][container.id] = up_status
    else:
        logger.info(f"Booting [{docker_project_service_name}] in [{docker_project_working_dir}]...")
        task_exec(
            status_map=task_status_map["up"],
            container=container,
            hook=task_unit_docker_compose_up
        )
        up_status = task_status_map["up"][container.id]

    # 记录任务总体状态
    task_status_map["summary"][container.id] = TaskStatus(
        container=container,
        retry_count=(build_status.retry_count + up_status.retry_count),
        last_time=(build_status.last_time + up_status.last_time),
        success=(build_status.success and up_status.success)
    )


container_interested_lebels = [
    "com.docker.compose.project",
    "com.docker.compose.service",
    "com.docker.compose.project.config_files"
]
for container_id, status in task_status_map["summary"].items():
    container = status.container
    build_status = task_status_map["build"][container_id]
    up_status = task_status_map["up"][container_id]

    container_labels = {}
    for label in container_interested_lebels:
        if label in container.labels:
            container_labels[label] = container.labels[label]

    container_info = {
        "name": container.name,
        "labels": container_labels
    }
    logger.info(f"Container info: {json.dumps(container_info)}")

    log_content = "build_status: " + \
        json.dumps(build_status.to_dict_without_container_field())
    if build_status.success:
        logger.success(log_content)
        log_content = "up_status: " + \
            json.dumps(up_status.to_dict_without_container_field())
        if up_status.success:
            logger.success(log_content)
        else:
            logger.error(log_content)
    else:
        logger.error(log_content)

program_end_time = datetime.now(tz=get_localzone())
logger.info("All done.")
logger.info(f"Total time: {(program_end_time - program_start_time).total_seconds()} second")
