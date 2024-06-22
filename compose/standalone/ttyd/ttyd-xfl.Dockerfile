FROM tsl0922/ttyd:alpine
RUN apk update
RUN apk add openssh bash bash-doc bash-completion bash-completion-doc mandoc man-pages util-linux coreutils utmps-dev htop
RUN apk add tzdata
ENV TZ=Asia/Hong_Kong
# RUN apk add doas
# RUN echo "" >> /etc/doas.conf && mkdir -p "/etc/doas.d/" && echo "permit nopass :root" >> "/etc/doas.d/doas.conf"
# RUN echo "permit nopass :root" >> /etc/doas.conf
RUN chmod 755 /usr/bin/ttyd
RUN mkdir -p /var/run/ttyd
RUN chmod 777 /var/run/ttyd
RUN adduser -D -s /bin/bash -h /home/ttyd -u 1000 ttyd
COPY --chmod=755 entrypoint.sh /entrypoint.sh
COPY --chmod=755 --from=resources entrypoint_common_environment_setup.sh /entrypoint_common_environment_setup.sh
ENTRYPOINT ["/sbin/tini", "-g", "--", "/entrypoint.sh"]
# WORKDIR /home/ttyd
# USER ttyd
