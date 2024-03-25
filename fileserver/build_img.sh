#!/bin/bash
set -e

if [[ ! -f linux-amd64-filebrowser.tar.gz ]]; then
    wget https://github.com/filebrowser/filebrowser/releases/download/v2.26.0/linux-amd64-filebrowser.tar.gz --no-check-certificate
fi

docker build -t fileserver:v1.0 .