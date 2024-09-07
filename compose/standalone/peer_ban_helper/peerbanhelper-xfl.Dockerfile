FROM ghostchu/peerbanhelper:latest
RUN apk update
RUN apk add openssh bash bash-doc bash-completion bash-completion-doc mandoc man-pages util-linux coreutils utmps-dev htop sudo tini
ADD https://github.com/PBH-BTN/PeerBanHelper/raw/master/Dockerfile /tmpDockerfile
RUN cat /tmpDockerfile | grep "ENTRYPOINT" | sed -e 's#^ENTRYPOINT \[##' -e 's#\]$##' | sed -e 's#", "# #g' -e 's#"##g' | sed -e 's#\,# #g' > /origin-entrypoint.txt
RUN rm /tmpDockerfile
COPY --chmod=755 my_entrypoint.sh /my_entrypoint.sh
COPY --chmod=755 --from=resources entrypoint_common_environment_setup.sh /entrypoint_common_environment_setup.sh
ENTRYPOINT ["/sbin/tini", "-g", "--", "/my_entrypoint.sh"]
