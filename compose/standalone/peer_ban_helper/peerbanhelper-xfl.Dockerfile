FROM ghostchu/peerbanhelper:latest
RUN apk update
RUN mkdir -p /tmp
COPY --chmod=644 --from=resources alpine_usually_used_packages.txt /tmp/alpine_usually_used_packages.txt
RUN apk add $(cat /tmp/alpine_usually_used_packages.txt) && rm /tmp/alpine_usually_used_packages.txt
RUN apk add openssh
# ADD https://github.com/PBH-BTN/PeerBanHelper/raw/master/Dockerfile /tmpDockerfile
# RUN cat /tmpDockerfile | grep "ENTRYPOINT" | sed -e 's#^ENTRYPOINT \[##' -e 's#\]$##' | sed -e 's#", "# #g' -e 's#"##g' | sed -e 's#\,# #g' > /origin-entrypoint.txt
ADD https://raw.githubusercontent.com/PBH-BTN/PeerBanHelper/refs/tags/v6.4.4/Dockerfile /tmpDockerfile
RUN cat /tmpDockerfile | grep "ENTRYPOINT" | sed -e 's#^ENTRYPOINT *##' > /origin-entrypoint.txt
RUN rm /tmpDockerfile
COPY --chmod=755 my_entrypoint.sh /my_entrypoint.sh
COPY --chmod=755 --from=resources entrypoint_common_environment_setup.sh /entrypoint_common_environment_setup.sh
ENTRYPOINT ["/sbin/tini", "-g", "--", "/my_entrypoint.sh"]
