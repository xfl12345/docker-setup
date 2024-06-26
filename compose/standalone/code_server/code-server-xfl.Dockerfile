FROM codercom/code-server:latest
RUN sudo apt update
RUN sudo apt install -y busybox htop
