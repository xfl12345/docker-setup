FROM tsl0922/ttyd:alpine
RUN apk update
RUN apk add openssh bash bash-doc bash-completion bash-completion-doc mandoc man-pages util-linux coreutils utmps-dev
RUN apk add doas && echo "permit nopass :root" >> "/etc/doas.d/doas.conf"
RUN chmod 755 /usr/bin/ttyd
RUN mkdir -p /var/run/ttyd
RUN chmod 777 /var/run/ttyd
RUN adduser -D -s /bin/bash -h /home/ttyd -u 1000 ttyd
COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh
WORKDIR /home/ttyd
# USER ttyd
ENTRYPOINT ["/sbin/tini", "-g", "--", "/entrypoint.sh"]