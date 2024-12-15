FROM alpine:edge
RUN mkdir -p /tmp
COPY --chmod=755 --from=resources ./* /tmp/xfl/build_resource/
RUN /tmp/xfl/build_resource/docker_build_install_usually_used_packages.sh && rm -rf /tmp/xfl
RUN apk add curl iptables iproute2 wireguard-tools-wg-quick bind-tools iputils fping
COPY --chmod=755 ./entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/sbin/tini", "-g", "--", "/entrypoint.sh"]
