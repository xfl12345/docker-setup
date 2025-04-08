FROM alpine:latest
ARG PING_NET 192.168.0.0/16
RUN mkdir -p /tmp
COPY --chmod=755 --from=resources ./* /tmp/xfl/build_resource/
RUN /tmp/xfl/build_resource/docker_build_install_usually_used_packages.sh && rm -rf /tmp/xfl
RUN apk add fping
ENV PING_NET $PING_NET
COPY --chmod=755 ./entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/sbin/tini", "-g", "--", "/entrypoint.sh"]
