# 欢迎来到通用 docker build 资源目录

## 文件说明

| 文件名 | 说明 |
|-:|:-|
|`alpine_usually_used_packages.txt`|包含一些 alpine linux 常用包的名称，用于补全运维环境|
|`docker-debian.sources`|提供 Docker 官方 APT 源样本，采用 DEB822 格式|
|`entrypoint_common_environment_setup.sh`|通用的 Docker 容器环境初始化脚本，负责完成 LINUX 账户配置、时区修正|

### 脚本变量说明

- entrypoint_common_environment_setup.sh

| 文件名 | 说明 |
|-:|:-|
|`TZ`|时区短代码，可以通过运行命令 `timedatectl list-timezones` 来获悉可用的值。权威标准详见 [Time Zone Database](https://www.iana.org/time-zones) 。指定该值将会修正容器环境时区|
|`PUID`|`PUID`即`Process User ID`。用于指定容器进程的 UID|
|`PGID`|`PGID`即`Process Group ID`。用于指定容器进程的 GID|
|`MY_DOCKER_APP_USER_NAME`|用于指定容器进程的用户名|
|`MY_DOCKER_APP_USER_HOME`|用于指定容器进程的用户的 `HOME` 目录|
|`MY_DOCKER_APP_USER_SHELL`|用于指定容器进程的用户的默认 SHELL|
|`MY_DOCKER_APP_USER_GROUP_NAME`|用户指定容器进程的用户的组名|
|`MY_DOCKER_APP_USER_ADD_GROUP_ID_LIST`|用户指定容器进程的用户所属的额外组的一群 ID 。其中，元素之间使用空格做间隔，元素类型必须是正整数|
