# 步骤

1. `systemctl stop docker.service && systemctl stop docker.socket`
2. `lsof +D /media/justsave` 检查是否有剩余进程在占用里面的子项目，有就用 kill 杀掉
3. 修改 `/etc/fstab` ，把属于 `/media/justsave` 的，改成 `/mnt/justsave`
4. `umount /media/justsave`
5. `systemctl daemon-reload && mount -a`
6. 移除或转移 `/media/justsave` 里所有的对象
7. `mount --bind /mnt/justsave /media/justsave`
8. `systemctl restart docker.service`
9. `mkdir -p ~/lab/python && cd ~/lab/python`
10. 安装并运行 [迁移小工具](https://gist.github.com/xfl12345/12eb4e3fa4ef69802c1d8d84b9882a30) 迁移小工具食用方法见 [tool_usage.md](./tool_usage.md)
11. 检查哪些容器工作不正常，自行手动修复
12. 手动搜索 `/mnt/justsave/docker/volume` 、 `/mnt/justsave/docker/compose` 以及 `/mnt/justsave/docker/env` 这些目录下的所有文本文件内容，将 `/media/` 替换为 `/mnt/` 并手动重创相关容器
13. `systemctl stop docker.service && systemctl stop docker.socket`
14. `lsof +D /media/justsave` 确保没有正在占用的目录
15. `umount /media/justsave && rm -r /media/justsave`
16. `systemctl restart docker.service`
17. 检查 `/media/justsave` 目录是否存在。若不存在，则迁移成功。若存在，请回到第 12 步再走一遍。
