# Headscale

## Official URL

- headscale

| 说明 | URL |
|-:|:-|
|repo|[https://github.com/juanfont/headscale](https://github.com/juanfont/headscale)|
|docs|[https://headscale.net/running-headscale-container/](https://headscale.net/running-headscale-container/)|

- headscale_webui

| 说明 | URL |
|-:|:-|
|repo|[https://github.com/iFargle/headscale-webui](https://github.com/iFargle/headscale-webui)|

- tailscale_client

| 说明 | URL |
|-:|:-|
|repo|[https://github.com/tailscale/tailscale](https://github.com/tailscale/tailscale)|
|docs|[https://tailscale.com/kb/1282/docker](https://tailscale.com/kb/1282/docker)|

## 郑重说明

- 请您 **务必** 阅读本项目 **根目录下** 的 `README.MD` 以免产生不必要的误会
- 请您 **一定要仔细阅** 读官方 ***最新*** 文档！本项目 ***不*** 做实时更新保证！最终解释归 APP 官方所有！

## 最少要求

### 资源准备

- 一个域名。例如 `headscale.hello.xfl12345`

### 最少环境配置要求

- headscale_webui

| 环境变量名 | 说明 |
|-:|:-|
|DOMAIN_NAME|官方没有具体解释，详情请参考 [https://github.com/iFargle/headscale-webui/blob/8501da138761dc776851376b157b31f332b2fe0e/docker-compose.yml](https://github.com/iFargle/headscale-webui/blob/8501da138761dc776851376b157b31f332b2fe0e/docker-compose.yml)|
|AUTH_TYPE|HTTP 鉴权方式|
|BASIC_AUTH_USER|RFC7617 标准下的鉴权用户名|
|BASIC_AUTH_PASS|RFC7617 标准下的鉴权密码|
|KEY|可以通过 openssl rand -base64 32 生成。官方没有具体解释，详情请参考 [https://github.com/iFargle/headscale-webui/blob/8501da138761dc776851376b157b31f332b2fe0e/docker-compose.yml](https://github.com/iFargle/headscale-webui/blob/8501da138761dc776851376b157b31f332b2fe0e/docker-compose.yml)|

- tailscale_client

| 环境变量名 | 说明 |
|-:|:-|
|TS_EXTRA_ARGS|Any other flags to pass in to the Tailscale CLI in a tailscale set command. 详情请参考 [https://tailscale.com/kb/1282/docker#ts_extra_args](https://tailscale.com/kb/1282/docker#ts_extra_args)|

## 环境配置举例

- headscale_webui

| 环境变量名 | 值 |
|-:|:-|
|DOMAIN_NAME|`https://headscale.hello.xfl12345:2083`|
|AUTH_TYPE|`Basic`|
|BASIC_AUTH_USER|`xfl12345`|
|BASIC_AUTH_PASS|`github@xfl12345`|
|KEY|`JLhrQ/rJC39wPhAdeUm+be3bcDtll5JQxJGXe9apN04=`|

- tailscale_client

| 环境变量名 | 值 |
|-:|:-|
|TS_EXTRA_ARGS|`"--advertise-tags=tag:container --netfilter-mode=off --login-server=https://headscale.hello.xfl12345:2083"`|

## 部署顺序推荐

- 完成域名解析配置

- 执行下面的命令

```bash
[ ! -e ./docker-compose.yml ] && ln -s ./docker-compose.example.yml docker-compose.yml
docker compose up -d --remove-orphans headscale
docker compose up -d --remove-orphans headscale_webui
```

- 按 [官方文档](https://headscale.net/running-headscale-container/) 完成 headscale 初始化  
  容器配置部分可以跳过，其余环节请结合本项目的约定来完成配置。例如约定好的 WebAPI 端口号
- 执行 `docker compose up -d --remove-orphans`
- 执行 `docker exec -it tailscale-client sh` 进入 tailscale 容器内部
- 在 tailscale 容器内部，按官方文档完成节点添加  
  - 参考文档 [https://tailscale.com/kb/1080/cli#login](https://tailscale.com/kb/1080/cli#login)
  - 假设 headscale 域名是 `headscale.hello.xfl12345`  
    那就执行 `tailscale login --login-server=https://headscale.hello.xfl12345:2083`  
    您会获得一个 key ，复制，打开 WebUI 管理页面 [https://headscale.hello.xfl12345:2083/admin/machines](https://headscale.hello.xfl12345:2083/admin/machines)  
    在右下角有一个印有“加号”的按钮，点击，弹窗里选择您之前配置的用户，填入之前复制的 key ，点击 `ADD MACHINE` 按钮  
