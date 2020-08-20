#!/bin/bash

cd "$(dirname "$0")"

SSH_PORT="52022"

if [ "$1" == "--build" ]; then
  docker build -t img_vpnc .
fi
if [ "$1" == "--run" ]; then
  docker run --privileged -p ${SSH_PORT}:22 -d -P --name cnt_vpnc img_vpnc
fi

if [ "$1" == "--ssh" ]; then
  # ssh root@localhost -p $(docker port cnt_vpnc 22 | cut -d':' -f2)
  ssh root@localhost -p ${SSH_PORT}
fi

if [ "$1" == "--stop" ]; then
  docker container stop cnt_vpnc
  docker container rm cnt_vpnc
fi

if [ "$1" == "--rm" ]; then
  docker image rm img_vpnc
  docker system prune
fi
