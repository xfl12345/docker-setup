FROM neilpang/acme.sh:latest
RUN  apk --no-cache add docker-cli py3-pip
# # 自动部署 SSL证书 到 阿里云CDN https://github.com/yxzlwz/ssl_update
# COPY /mnt/justsave/docker/volume/acme_sh/ssl_update /ssl_update
# RUN pip install -r /ssl_update/requirements.txt
