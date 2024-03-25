ARG FROM_IMAGE=ubuntu:20.04
FROM $FROM_IMAGE

LABEL description="fileserver: sftp + samba + ftp + nginx + filebrowser"

ENV TZ='Asia/Shanghai'
ENV LANG="C.UTF-8"

RUN echo "root:root" | chpasswd \
    && ln -sf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone 

RUN echo 'export LANG="C.UTF-8"' >> /root/.bashrc \
    && echo 'export LC_ALL="C"' >> /root/.bashrc \
    && echo 'cd /mnt' >> /root/.bashrc

RUN ln -sf /bin/bash /bin/sh

RUN sed -i s@/archive.ubuntu.com/@/mirrors.tuna.tsinghua.edu.cn/@g /etc/apt/sources.list \
    && apt clean

RUN apt update 

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

# tools
    # bash-completion \
# RUN apt install -y \
#     vim \
#     unzip \
#     tar

# install ssh
RUN apt install openssh-server -y \
    && mkdir -p /mnt/data/sftp \
    && sed -i 's/\#PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config \
    && sed -i "s/Subsystem/#&/g" /etc/ssh/sshd_config   \
    && echo "Subsystem sftp internal-sftp"    >> /etc/ssh/sshd_config \
    && echo "Match User root"                 >> /etc/ssh/sshd_config \
    && echo "ChrootDirectory /mnt/data/sftp"  >> /etc/ssh/sshd_config \
    && echo "X11Forwarding no"                >> /etc/ssh/sshd_config \
    && echo "AllowTcpForwarding no"           >> /etc/ssh/sshd_config \
    && echo "PermitTTY no"                    >> /etc/ssh/sshd_config \
    && echo "ForceCommand internal-sftp"      >> /etc/ssh/sshd_config


RUN apt install -y vsftpd \
    && mkdir -p /mnt/data/ftp \
    && echo "local_root=/mnt/data/ftp"     >> /etc/vsftpd.conf \
    && echo "pasv_enable=YES"              >> /etc/vsftpd.conf \
    && echo "port_promiscuous=YES"         >> /etc/vsftpd.conf \
    && echo "pasv_promiscuous=YES"         >> /etc/vsftpd.conf \
    && echo "pasv_min_port=10000"          >> /etc/vsftpd.conf \
    && echo "pasv_max_port=10010"          >> /etc/vsftpd.conf \
    && echo "write_enable=YES"             >> /etc/vsftpd.conf \
    && echo "chroot_local_user=YES"        >> /etc/vsftpd.conf \
    && echo "allow_writeable_chroot=YES"   >> /etc/vsftpd.conf \
    && sed -i "/root/d" /etc/ftpusers



RUN apt install -y samba \
    && mkdir -p /mnt/data/samba \
    && echo "[root]"                           >> /etc/samba/smb.conf \
    && echo "   comment = smbuser Media File"  >> /etc/samba/smb.conf \
    && echo "   path = /mnt/data/samba"        >> /etc/samba/smb.conf \
    && echo "   valid user = root"             >> /etc/samba/smb.conf \
    && echo "   guest ok = no"                 >> /etc/samba/smb.conf \
    && echo "   read only = no"                >> /etc/samba/smb.conf \
    && echo "   write list = root"             >> /etc/samba/smb.conf \
    && echo "   browseable = no"               >> /etc/samba/smb.conf \
    && echo "   create mask = 0755"            >> /etc/samba/smb.conf \
    && echo "   directory mask = 0755"         >> /etc/samba/smb.conf \
    && echo "   admin user = root"             >> /etc/samba/smb.conf


COPY ./linux-amd64-filebrowser.tar.gz /etc/filebrowser/

RUN cd /etc/filebrowser     \
    && tar -xvf linux-amd64-filebrowser.tar.gz    \
    && rm linux-amd64-filebrowser.tar.gz

RUN apt install -y nginx \
    && sed -i '\#server_name _;#a\\tlocation /filebrowser {proxy_pass http://localhost:10080/filebrowser;}' /etc/nginx/sites-available/default

RUN apt autoclean -y \
    && apt autoremove -y \
    && rm -rf /var/lib/apt/lists/*


COPY ./startup.sh /etc

ENV WORKDIR="/mnt"
WORKDIR $WORKDIR

ENTRYPOINT ["/bin/bash","/etc/startup.sh"]
