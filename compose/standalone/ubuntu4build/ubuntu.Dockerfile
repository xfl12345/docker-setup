FROM ubuntu:24.04
RUN apt update
RUN apt upgrade -y
RUN apt install -y apt-transport-* ca-certificates software-properties-common curl wget
RUN apt install -y apt-file apt-utils busybox tar xzip xz-utils net-tools sudo lsb-release bind9-dnsutils tzdata
RUN apt install -y qemu-user-static debootstrap fakeroot screen systemd-timesyncd tini
RUN apt install -y python3 python3-dev python3-pip pipx gcc make cmake gdb m4 autoconf automake git bc bison flex pahole cpio rsync kmod
RUN apt install -y libtool build-essential crossbuild-essential-amd64 crossbuild-essential-arm* crossbuild-essential-mips* pkg-config
RUN apt install -y libssl-dev make libc6-dev libelf-dev libncurses5-dev zlib1g-dev
RUN apt install -y qemu-user-static debootstrap fakeroot screen systemd-timesyncd
RUN apt install -y apt-utils wget curl busybox util-linux-extra tar xzip xz-utils net-tools sudo lsb-release
RUN apt install -y libgpiod2 libgpiod-dev gpiod python3-periphery openssh-server zip unzip
# 不允许SSH远程登录，防止密码泄漏后被作为字典从网络爆破入侵
RUN sed -i 's#PermitRootLogin without-password#PermitRootLogin no#g' /etc/ssh/sshd_config
RUN bash -c 'echo -e "\n\nPasswordAuthentication yes\n" >> /etc/ssh/sshd_config'
# 新建 sudoer 普通用户
RUN useradd -m xflworker
RUN echo 'xflworker:iamjustaworker,wtfhacker' | chpasswd
RUN mkdir -p /etc/sudoers.d
RUN echo 'xflworker ALL=(ALL:ALL) ALL' >> /etc/sudoers.d/xflworker
RUN chmod 0440 /etc/sudoers.d/xflworker
# RUN mkdir -p /home/xflworker/
# RUN chown xflworker:xflworker -R /home/xflworker/
COPY --chmod=755 --from=resources ./infinite_sleep_loop.sh /infinite_sleep_loop.sh
COPY --chmod=755 ./entrypoint.sh /
ENTRYPOINT [ "/usr/bin/tini", "--" ,"/entrypoint.sh" ]
USER xflworker
WORKDIR /home/xflworker/
