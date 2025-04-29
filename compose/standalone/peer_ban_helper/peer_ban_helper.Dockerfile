FROM ghostchu/peerbanhelper:latest
RUN apt update && apt upgrade -y
COPY --chmod=755 --from=resources ./* /tmp/xfl/build_resource/
RUN /tmp/xfl/build_resource/docker_build_install_usually_used_packages.sh && rm -rf /tmp/xfl
RUN apt install -y openssh-*
# ADD https://github.com/PBH-BTN/PeerBanHelper/raw/master/Dockerfile /tmpDockerfile
# RUN cat /tmpDockerfile | grep "ENTRYPOINT" | sed -e 's#^ENTRYPOINT \[##' -e 's#\]$##' | sed -e 's#", "# #g' -e 's#"##g' | sed -e 's#\,# #g' > /origin-entrypoint.txt
# ADD https://raw.githubusercontent.com/PBH-BTN/PeerBanHelper/refs/heads/master/Dockerfile-Release /tmpDockerfile
ADD https://raw.githubusercontent.com/PBH-BTN/PeerBanHelper/refs/tags/v7.0.0-beta2/Dockerfile /tmpDockerfile
RUN cat /tmpDockerfile | grep -oE "ENTRYPOINT .*$" | sed -e 's#^ENTRYPOINT ##' > /origin-entrypoint.txt
RUN rm /tmpDockerfile
COPY --chmod=755 my_entrypoint.sh /my_entrypoint.sh
COPY --chmod=755 --from=resources entrypoint_common_environment_setup.sh /entrypoint_common_environment_setup.sh
# ENTRYPOINT ["/usr/bin/tini", "-g", "--", "/my_entrypoint.sh"]
ENTRYPOINT ["/usr/bin/env", "tini", "-g", "--", "/my_entrypoint.sh"]
