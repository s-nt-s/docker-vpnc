#!/bin/bash
/usr/sbin/sshd -D &
/usr/sbin/vpnc default --no-detach --non-inter
