#!/bin/sh

# 设置捕获 SIGTERM 和 SIGINT 信号
handle_signal() {
  echo "Received termination signal, exiting..."
  kill -- -$$ # 发送信号给进程组中的所有进程
}

trap 'handle_signal' TERM INT

# 启动子 shell 进行无限循环
(
  while true; do
    sleep 999999999d || exit
  done
) &

# 等待子进程结束
wait $!
