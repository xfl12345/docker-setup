FROM tsl0922/ttyd:alpine
RUN apk update
RUN mkdir -p /tmp
COPY --chmod=644 --from=resources alpine_usually_used_packages.txt /tmp/alpine_usually_used_packages.txt
RUN apk add $(cat /tmp/alpine_usually_used_packages.txt) && rm /tmp/alpine_usually_used_packages.txt
RUN apk add openssh utmps-dev htop
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
