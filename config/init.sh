#!/bin/sh
/usr/sbin/sshd
/usr/sbin/vpnc default --non-inter --pid-file /var/run/vpnc.pid
/usr/sbin/sockd
