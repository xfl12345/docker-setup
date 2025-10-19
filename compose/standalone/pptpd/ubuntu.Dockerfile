FROM alpine/curl-http3 AS geo-helper
RUN mkdir -p /tmp
RUN EDGE_NODE_NUM=$((RANDOM % 256)) && curl -sL "http://172.67.100.${EDGE_NODE_NUM}/cdn-cgi/trace" | grep loc | cut -d'=' -f2 > /tmp/the-geo

FROM ubuntu:jammy
COPY --chmod=+x ./apt_source_init.sh /tmp/apt_source_init.sh
COPY --from=geo-helper /tmp/the-geo /tmp/the-geo
RUN bash /tmp/apt_source_init.sh
RUN rm /tmp/the-geo
RUN apt update
RUN apt upgrade -y
RUN apt install -y wget curl busybox-static tar xzip xz-utils net-tools sudo pptpd rsyslog
RUN chmod 666 /dev/stdout /dev/stderr
RUN echo "*.* /dev/stdout" > /etc/rsyslog.d/docker.conf
# RUN echo "daemon.* /dev/stdout" > /etc/rsyslog.d/docker.conf && \
#     echo "*.debug /dev/stdout" >> /etc/rsyslog.d/docker.conf

# Expose PPTP port
EXPOSE 1723/tcp

USER root
SHELL ["/usr/bin/bash", "-c"]
CMD ["bash", "-c", "chmod 666 /dev/stdout /dev/stderr && rsyslogd && /usr/sbin/pptpd -f"]
