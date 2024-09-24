FROM metacubex/mihomo:v1.18.6 AS clash
FROM gitea/act_runner:latest
RUN apk update
RUN apk add busybox bash bash-doc bash-completion bash-completion-doc mandoc man-pages util-linux coreutils
RUN apk add iptables ip6tables iproute2 ipset
RUN apk add curl wget
COPY --from=clash /mihomo /mihomo
# COPY --chmod=07777 ./entrypoint.sh /entrypoint.sh
COPY --chmod=777 ./entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/sbin/tini", "--" ,"/entrypoint.sh" ]
