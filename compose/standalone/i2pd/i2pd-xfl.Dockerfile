FROM purplei2p/i2pd:latest
USER root
RUN apk update
RUN apk add openssh bash bash-doc bash-completion bash-completion-doc mandoc man-pages util-linux coreutils utmps-dev htop sudo tini tzdata
COPY --chmod=755 my_entrypoint.sh /my_entrypoint.sh
COPY --chmod=755 --from=resources entrypoint_common_environment_setup.sh /entrypoint_common_environment_setup.sh
ENTRYPOINT ["/sbin/tini", "-g", "--", "/my_entrypoint.sh"]
