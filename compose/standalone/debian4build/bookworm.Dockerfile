FROM debian:bookworm
# ENV TZ=Asia/Shanghai
ENV TZ=Asia/Hongkong
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata
RUN apt update
RUN apt upgrade -y
RUN apt install -y tzdata
RUN apt install -y apt-utils wget curl busybox util-linux-extra tar xzip xz-utils net-tools sudo lsb-release
RUN apt install -y qemu-user-static debootstrap fakeroot screen systemd-timesyncd
RUN apt install -y python3 python3-dev python3-pip pipx gcc make cmake gdb m4 autoconf automake git bc bison flex pahole cpio rsync kmod
RUN apt install -y libgpiod2 libgpiod-dev gpiod python3-periphery openssh-server
# 不允许SSH远程登录，防止密码泄漏后被作为字典从网络爆破入侵
RUN sed -i 's#PermitRootLogin without-password#PermitRootLogin no#g' /etc/ssh/sshd_config
RUN echo -e "\n\nPasswordAuthentication no\n" >> /etc/ssh/sshd_config
# 新建 sudoer 普通用户
RUN useradd -m xflworker
RUN echo 'xflworker:iamjustawork,wtfhacker!' | chpasswd
RUN mkdir -p /etc/sudoers.d
RUN echo "xflworker ALL=(ALL:ALL) ALL" >> /etc/sudoers.d/xflworker
RUN chmod 0440 /etc/sudoers.d/xflworker
USER xflworker
WORKDIR /home/xflworker
