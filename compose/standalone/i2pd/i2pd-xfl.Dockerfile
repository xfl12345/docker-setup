FROM purplei2p/i2pd:latest
USER root
RUN apk update
RUN mkdir -p /tmp
COPY --chmod=644 --from=resources alpine_usually_used_packages.txt /tmp/alpine_usually_used_packages.txt
RUN apk add $(cat /tmp/alpine_usually_used_packages.txt) && rm /tmp/alpine_usually_used_packages.txt
COPY --chmod=755 my_entrypoint.sh /my_entrypoint.sh
COPY --chmod=755 --from=resources entrypoint_common_environment_setup.sh /entrypoint_common_environment_setup.sh
ENTRYPOINT ["/sbin/tini", "-g", "--", "/my_entrypoint.sh"]
