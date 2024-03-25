ARG FROM_IMAGE=ubuntu:20.04
FROM $FROM_IMAGE

LABEL description="Integrated compilation environment"

ENV TZ='Asia/Shanghai'
# ENV TZ='Etc/UTC'
ENV LANG="C.UTF-8"

RUN echo "root:root" | chpasswd \
    && ln -sf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone 


RUN echo 'export LANG="C.UTF-8"' >> /root/.bashrc \
    && echo 'export LC_ALL="C"' >> /root/.bashrc \
    && echo 'cd /work' >> /root/.bashrc
    
RUN sed -i s@/archive.ubuntu.com/@/mirrors.tuna.tsinghua.edu.cn/@g /etc/apt/sources.list \
    && apt-get clean

RUN apt-get update 

# 为pid0设置中文环境
# ENV LANG="zh_CN.UTF-8" \
#     LANGUAGE="zh_CN:zh:en_US:en" \
#     LC_ALL="zh_CN.UTF-8"
# LANG="en_US.UTF-8"

# RUN apt-get clean \
#     && apt-get update \
    # && apt-get install -y language-pack-zh-hans \
    # && update-locale LANG="zh_CN.UTF-8" LANGUAGE="zh_CN:zh:en_US:en" LC_ALL="zh_CN.UTF-8" \
    ##不设置这个导致直接进容器中文，但是远程桌面显示还是英文


# install ssh
RUN apt-get install openssh-server -y \
    && sed -i 's/\#PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
    # && echo "PermitRootLogin yes" > /etc/ssh/sshd_config

# tools
RUN apt-get install -y \
    bash-completion \
    iputils-ping \
    vim \
    git \
    gcc \
    g++ \
    make \
    cmake \
    unzip \
    tzdata \
    net-tools \
    sshpass \
    curl \
    openjdk-11-jdk \
    sudo \
    busybox \
    bc \
    tree \
    tar \
    u-boot-tools \
    libncurses5-dev

RUN curl https://mirrors.tuna.tsinghua.edu.cn/git/git-repo -o /usr/bin/repo \
    && chmod +x /usr/bin/repo \
    && ln -sf /usr/bin/python3 /usr/bin/python

RUN ln -sf /bin/bash /bin/sh

RUN apt-get autoclean -y \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*


COPY ./startup.sh /etc

ENV WORKDIR="/work"
WORKDIR $WORKDIR

ENTRYPOINT ["/bin/bash","/etc/startup.sh"]