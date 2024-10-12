FROM metacubex/mihomo:v1.18.6 AS clash
FROM gitea/act_runner:latest
RUN apk update
RUN mkdir -p /tmp
COPY --chmod=644 --from=resources alpine_usually_used_packages.txt /tmp/alpine_usually_used_packages.txt
RUN apk add $(cat /tmp/alpine_usually_used_packages.txt) && rm /tmp/alpine_usually_used_packages.txt
RUN apk add iptables ip6tables iproute2 ipset
RUN apk add curl wget
COPY --from=clash /mihomo /mihomo
# COPY --chmod=07777 ./entrypoint.sh /entrypoint.sh
COPY --chmod=777 ./entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/sbin/tini", "--" ,"/entrypoint.sh" ]
