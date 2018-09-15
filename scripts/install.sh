#!/usr/bin/env bash

set -ex
set -o pipefail

install_docker() {
  apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
  apt-add-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
  apt update
  apt install -y docker-ce
}

main() {
  apt update
  install_docker

  mkdir /var/lib/athens
  docker run -d \
    -v /var/lib/athens:/var/lib/athens \
    -e ATHENS_DISK_STORAGE_ROOT=/var/lib/athens \
    -e ATHENS_STORAGE_TYPE=disk \
    --name athens-proxy \
    --restart always \
    -p 3000:3000 \
    gomods/proxy:latest
}

main $@
