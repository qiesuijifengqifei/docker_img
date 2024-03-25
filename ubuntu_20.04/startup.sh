#!/bin/bash
set -e
# PID_SUB=$!
OPT=$@

echo "USER_PASSWORD : ${USER_PASSWORD}"
echo "root:${USER_PASSWORD}" | chpasswd

service ssh start

if [[ -f /work/startup.sh ]]; then
    echo "bash /work/startup.sh "
    bash /work/startup.sh &
fi


# apt update > /dev/null 2>&1 

if [ -z "${OPT}" ]; then
    # wait $PID_SUB
    echo "no command ,Executing bash"
    echo "start success"
    bash
else
    # unknown option ==> call command
    echo -e "\n\n------------------ EXECUTE COMMAND ------------------"
    echo "Executing command: '${OPT}'"
    ${OPT}
    
    # 多个命令可以通过command： source 脚本
    # exec "$@"

    echo "start success , Executing bash"
    bash
    echo "end"
fi
