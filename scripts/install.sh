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
  apt-get update
  install_docker

  mkdir /var/lib/athens
  systemctl daemon-reload
  systemctl enable athens
  systemctl start athens
}

main "$@"
