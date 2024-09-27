FROM alpine:latest
ENV TZ=Asia/Hong_Kong
RUN apk update
RUN mkdir -p /tmp
COPY --chmod=755 --from=resources alpine_usually_used_packages.txt /tmp/alpine_usually_used_packages.txt
RUN apk add $(cat /tmp/alpine_usually_used_packages.txt) && rm /tmp/alpine_usually_used_packages.txt
RUN apk add docker-cli docker-cli-compose
RUN apk add curl yq-go jq
COPY --chmod=755 --from=resources entrypoint_common_environment_setup.sh /entrypoint_common_environment_setup.sh
COPY --chmod=755 default.env /my_default.env
COPY --chmod=755 updater.sh /updater.sh
COPY --chmod=755 my_entrypoint.sh /my_entrypoint.sh
ENTRYPOINT ["/sbin/tini", "-g", "--", "/my_entrypoint.sh"]
