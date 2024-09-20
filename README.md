# docker-setup

高度可复用的 docker 配置，开源出来方便大家抄作业，同时制定虚空标准。  

## 说明与约定

- 所有 docker APP 相关的配置文件和持久化数据都应位于 `/media/justsave/docker` 目录之下。**后文相对路径均以该目录为根目录**。  
- 所有目录名称命名不得含有中横线以及其它特殊符号。若一定要有，则使用下划线代替。  
- 所有 APP 配置均必须以各自 APP 的名称新建一个该 APP 的专属目录，禁止“乱拉屎”。必须遵守该约定的目录包括但不限于 `./compose/standalone` 、 `./env` 和 `./volume` 。  
- `./compose` 是存放所有 docker compose 配置文件 `docker-compose.yml` 的目录。  
- `./compose` 的所有子对象（除了文件名为 `docker-compose.yml` 的文件）不得包含敏感信息的配置，以保持可安全开源的状态。  
- `./compose` 的所有子对象中，文件名为 `docker-compose.yml` 的文件，推荐使用 `extends` 或者 `include` 关键字引用 `docker-compose*.example.yml` 文件，以便获得持续的维护支持同时减少空间占用。  
- `./env` 是存放所有包含敏感信息的配置文件的目录。应始终保持防止添加到 git 仓库。  
- docker compose 涉密环境变量存放到 `./env` 并使用关键字 `env_file` 引用。  
- 所有 APP 的 docker compose 配置文件的目录都只能存放在目录 `./compose/standalone` 。
- `./compose/all_in_one` 是存放投入生产的 docker compose 配置文件的目录。用以方便重装系统后只用一条命令拉起所有已配置的已投入过生产的 docker 容器，也为了方便统一管理生产 APP 以及指定 APP 开机启动的先后顺序。  
- `./compose/standalone` 目录这般结构，是为了方便命令行 cd 进目录时，直接一条 `docker compose up -d` 运行 APP 。  
- `./compose` 目录下的所有子对象中，文件名为 `default.env` 的文件不允许自行修改，由本项目控制。  
- `./volume` 是存放所有 docker APP 持久化数据的默认目录。  
- 每新增一个不能登录的系统普通用户时，往 `./compose/user_init.sh` 里添加，使用脚本完成用户添加，而非手动敲 useradd/adduser 命令，毕竟人总是非常容易犯错的。  
- Web APP 端口号固定。需要添加请开 Pull Request 。  

## 食用准备

- 需要运行一次 `./compose/user_init.sh` ，然后再跑容器。
- （可选）运行一次 `./compose/local_build_image_update.sh install` 用以实现自动更新通过本地构建镜像的容器。

## WebAPP 端口号分配

| 端口号 | 用途 |
|:-:|:-|
|28000|`reserved`|
|28001|clash web API|
|28002|clash web UI|
|28003~28008|`reserved`|
|28009|phpMyAdmin|
|28010|XFL的个人简历 Web APP|
|28011|Jenkins|
|28012|qBittorrent Web UI|
|28013|GitLab|
|28014|Gitea|
|28015|Headscale Web API|
|28016|Headscale ADMIN Web UI|
|28017|wg-easy|
|28018|HertzBeat|
|28019|Portainer|
|28020|Netmaker dashboard Web UI|
|28021|Netmaker Web API|
|28022|Netmaker broker|
|28023~28029|`reserved`|
|28030|Netmaker dashboard Web UI|
|28031|Netmaker Web API|
|28032|Netmaker broker|
|28033~28039|`reserved`|
|28040|Glances Web UI|
|28041|Netdata Web UI|
|28042|code-server|
|28043|BitComet|
|28044|n.eko|
|28045|libreoffice|
|28046|mayfly-go|
|28047|`reserved`|
|28048|PeerBanHelper|
|28049~28099|`reserved`|

## Docker Tag 指定情况 （不含强依赖镜像）  

- 所谓“强依赖”，指的是官方文档指定的版本号，但不是全局版本唯一的镜像。  

| 镜像名 | tag |
|-:|:-|
|`neilpang/acme.sh`|`latest`|
|`busybox`|NULL|
|`metacubex/mihomo`|`v1.18.6`|
|`ghcr.io/metacubex/metacubexd`|NULL|
|`codercom/code-server`|`latest`|
|`ghcr.io/curl/curl-container/curl`|`master`|
|`jeessy/ddns-go`|`latest`|
|`debian`|`bookworm`|
|`gitea/gitea`|`1.22`|
|`yrzr/gitlab-ce-arm64v8`|`16.10.1-ce.0`|
|`nicolargo/glances`|`latest-full`|
|`headscale/headscale`|`0.22.3`|
|`ifargle/headscale-webui`|`latest`|
|`tailscale/tailscale`|`latest`|
|`apache/hertzbeat`|NULL|
|`purplei2p/i2pd`|`latest`|
|`linuxserver/libreoffice`|`latest`|
|`jenkins/jenkins`|`lts-jdk17`|
|`mariadb`|`11`|
|`https://gitee.com/dromara/mayfly-go.git`|`v1.8.8`|
|`irinesistiana/mosdns`|`v5.3.1`|
|`m1k1o/neko`|`chromium`|
|`netdata/netdata`|NULL|
|`gravitl/netclient`|`v0.25.0`|
|`gravitl/netmaker`|`v0.25.0`|
|`gravitl/netmaker-ui`|`v0.25.0`|
|`eclipse-mosquitto`|`2.0.15-openssl`|
|`nginx`|`latest`|
|`ghostchu/peerbanhelper`|`latest`|
|`php`|`7.4-fpm-bullseye`|
|`phpmyadmin`|NULL|
|`portainer/portainer-ce`|`latest`|
|`ghcr.io/heyputer/puter`|`sha-ec31007`|
|`linuxserver/qbittorrent`|`latest`|
|`redroid/redroid`|`13.0.0-latest`|
|`linuxserver/transmission`|`latest`|
|`tsl0922/ttyd`|`alpine`|
|`ubuntu`|`24.04`|
|`watchtower`|`latest`|
|`ghcr.io/wg-easy/wg-easy`|NULL|
|`neilpang/wgcf-docker`|NULL|
|`curriculum-vitae-web-server`|NULL|
|`teddysun/xray`|`latest`|
|`wxhere/bitcomet`|`latest`|
