ARG BASE_IMAGE_TAG=jenkins/jenkins:lts-jdk17
FROM ${BASE_IMAGE_TAG}
USER root
# COPY --chmod=764 --from=resources docker-debian.sources /etc/apt/sources.list.d/docker.sources
RUN apt update
RUN apt install -y busybox
# RUN apt install -y tini doas
# RUN echo "permit nopass :root" >> /etc/doas.conf
# RUN apt remove -y docker.io docker-doc docker-compose podman-docker containerd runc
# RUN apt install -y docker-ce-cli
# RUN ls -lah && pwd
COPY --chmod=755 entrypoint.sh /entrypoint.sh
COPY --chmod=755 --from=resources entrypoint_common_environment_setup.sh /entrypoint_common_environment_setup.sh
ENTRYPOINT ["tini", "-g", "--", "/entrypoint.sh"]
