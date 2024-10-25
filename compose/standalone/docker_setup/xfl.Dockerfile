FROM python:3-alpine3.20 AS compiler
ENV PYTHONUNBUFFERED 1
RUN mkdir /app
WORKDIR /app
RUN python3 -m venv myvenv
# Enable venv
ENV PATH="/app/myvenv/bin:$PATH"
RUN pip3 install --upgrade pip
RUN pip3 install wheel
RUN pip3 install docker
COPY /app/requirements.txt /app/requirements.txt
RUN pip3 install -Ur requirements.txt

# FROM alpine:3.19
FROM python:3-alpine3.20
ENV TZ=Asia/Hong_Kong
RUN apk update
RUN mkdir -p /tmp
COPY --chmod=644 --from=resources alpine_usually_used_packages.txt /tmp/alpine_usually_used_packages.txt
RUN apk add $(cat /tmp/alpine_usually_used_packages.txt) && rm /tmp/alpine_usually_used_packages.txt
RUN apk add docker-cli docker-cli-compose
RUN apk add curl yq-go jq
COPY --chmod=755 app /app
WORKDIR /app
COPY --from=compiler /app/myvenv /app/myvenv
ENV PATH="/app/myvenv/bin:$PATH"
# RUN chmod 755 -R /app/
RUN mkdir -p /usr/local/share/Docker
COPY --chmod=755 --from=resources entrypoint_common_environment_setup.sh /entrypoint_common_environment_setup.sh
COPY --chmod=755 default.env /usr/local/share/Docker/default.env
COPY --chmod=755 entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/sbin/tini", "-g", "--", "/entrypoint.sh"]
