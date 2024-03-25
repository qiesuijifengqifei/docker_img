#!/bin/bash
# set -e
# PID_SUB=$!
OPT=$@

# USER_PASSWORD=
# SFTP_ENABLE=
# FTP_ENABLE=
# FTP_PASV_MIN_PORT=
# FTP_PASV_MAX_PORT=
# SAMBA_ENABLE=
# SAMBA_USER_PASSWORD=
# FILEBROWSER_USER_PASSWORD=

      # - "10022:22"                      # sftp
      # - "21:21"                         # ftp
      # - "20:20"                         # ftp 主动模式
      # - "10000-10010:10000-10010"       # ftp 被动模式
      # - "80:80"                         # http
      # - "139:139"                       # samba
      # - "445:445"                       # samba

function set_env() {
    if [[ -z "${USER_PASSWORD}" ]]; then
        USER_PASSWORD="root"
    fi

    if [[ -z "${SAMBA_USER_PASSWORD}" ]]; then
        SAMBA_USER_PASSWORD="${USER_PASSWORD}"
    fi

    if [[ -z "${FILEBROWSER_USER_PASSWORD}" ]]; then
        FILEBROWSER_USER_PASSWORD="${USER_PASSWORD}"
    fi

    # echo "USER_PASSWORD : ${USER_PASSWORD}"
    echo "root:${USER_PASSWORD}" | chpasswd > /dev/null
}


function set_ftp() {
    if [[ -z "${FTP_ENABLE}" ]]; then
        if [[ -n "${FTP_PASV_MIN_PORT}" && -n "${FTP_PASV_MAX_PORT}" ]]; then
            sed -i "s#pasv_min_port.*#pasv_min_port=${FTP_PASV_MIN_PORT}#g" /etc/vsftpd.conf
            sed -i "s#pasv_max_port.*#pasv_max_port=${FTP_PASV_MAX_PORT}#g" /etc/vsftpd.conf
        fi

        if [[ ! -d /mnt/data/ftp ]]; then
            mkdir -p /mnt/data/ftp
        fi
        service vsftpd start
    fi
}

function set_sftp() {
    if [[ -z "${SFTP_ENABLE}" ]]; then
        if [[ ! -d /mnt/data/sftp ]]; then
            mkdir -p /mnt/data/sftp
        fi
        service ssh start
    fi
}

function set_samba() {
    if [[ -z "${SAMBA_ENABLE}" ]]; then
        if [[ -f /etc/samba/smb.conf ]]; then
            if [[ -f /mnt/samba/smb.conf ]]; then
                rm /etc/samba/smb.conf
            else
                echo "samba: This is the first startup, initialization configuration"
                mkdir -p /mnt/samba
                mv /etc/samba/smb.conf /mnt/samba
            fi

            ln -s /mnt/samba/smb.conf /etc/samba/smb.conf
            (echo ${SAMBA_USER_PASSWORD};echo ${SAMBA_USER_PASSWORD}) | smbpasswd -a root > /dev/null
        fi

        if [[ ! -d /mnt/data/samba ]]; then
            mkdir -p /mnt/data/samba
        fi
        service smbd start
    fi
}


function set_nginx() {
    if [[ ! -d /mnt/nginx ]]; then
        mkdir -p /mnt/nginx
    fi

    if [[ -f /etc/nginx/sites-available/default ]]; then
        if [[ -f /mnt/nginx/default ]]; then
            rm /etc/nginx/sites-available/default
        else
            mv /etc/nginx/sites-available/default /mnt/nginx
        fi
        ln -s /mnt/nginx/default /etc/nginx/sites-available/default
    fi

    if [[ -f /var/www/html/index.nginx-debian.html ]]; then
        if [[ -f /mnt/nginx/index.nginx-debian.html ]]; then
            rm /var/www/html/index.nginx-debian.html
        else
            mv /var/www/html/index.nginx-debian.html /mnt/nginx
        fi
        ln -s /mnt/nginx/index.nginx-debian.html /var/www/html/index.nginx-debian.html
    fi

    service nginx start
}

function set_filebrowser() {

    if [[ ! -f /mnt/filebrowser/filebrowser.db ]]; then
        echo "filebrowser: This is the first startup, initialization configuration"
        /etc/filebrowser/filebrowser --database "/mnt/filebrowser/filebrowser.db" config init > /dev/null
        /etc/filebrowser/filebrowser --database "/mnt/filebrowser/filebrowser.db" users add root ${FILEBROWSER_USER_PASSWORD} --perm.admin > /dev/null
    fi
    # reset filebrowser password
    # /etc/filebrowser/filebrowser --database "/mnt/filebrowser/filebrowser.db" users update root -p ${FILEBROWSER_USER_PASSWORD} > /dev/null

    /etc/filebrowser/filebrowser --database "/mnt/filebrowser/filebrowser.db" --port 10080 --root /mnt/data --baseurl "/filebrowser" &
    echo -e " * Starting filebrowser\n   ...done."

}

function startup() {
    if [[ -f /mnt/startup.sh ]]; then
        echo "file /mnt/startup.sh exists. bash /mnt/startup.sh"
        bash /mnt/startup.sh &
    fi
    # apt update > /dev/null 2>&1 

    set_env
    set_ftp
    set_sftp
    set_samba
    set_nginx
    set_filebrowser

    echo "------------------------------"
    echo "|  fileserver start success  |"
    echo "------------------------------"

}

startup


if [[ -z "${OPT}" ]]; then
    # wait $PID_SUB
    echo "no command ,Executing bash"
    bash
else
    # unknown option ==> call command
    echo -e "\n\n------------------ EXECUTE COMMAND ------------------"
    echo "Executing command: '${OPT}'"
    ${OPT}

fi
