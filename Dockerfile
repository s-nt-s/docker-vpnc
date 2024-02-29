FROM alpine:latest

# https://docs.docker.com/engine/examples/running_ssh_service/
# https://unix.stackexchange.com/a/170871/235763

COPY config/default.conf /etc/vpnc/default.conf
COPY config/init.sh /root/init.sh
COPY config/authorized_keys /home/vpnc/.ssh/

RUN \
apk update && \
apk add --no-cache openssh-server vpnc sudo && \
sed -E 's|^#?AllowTcpForwarding.*|AllowTCPForwarding yes|g' -i /etc/ssh/sshd_config && \
sed -E 's|^#?ChallengeResponseAuthentication.*|ChallengeResponseAuthentication no|g' -i /etc/ssh/sshd_config && \
sed -E 's|^#?PasswordAuthentication.*|PasswordAuthentication no|g' -i /etc/ssh/sshd_config && \
sed -E 's|\s\s*| |g' -i /etc/ssh/sshd_config && \
sed -E '/^#/d' -i /etc/ssh/sshd_config && \
sed -E '/^\s*$/d' -i /etc/ssh/sshd_config && \
adduser --disabled-password --home /home/vpnc vpnc && \
mkdir -p /home/vpnc/.ssh/ && \
chmod 700 /root/init.sh && \
chmod 600 /home/vpnc/.ssh/authorized_keys && \
chown vpnc:vpnc -R /home/vpnc/ && \
sed 's|^vpnc:!:|vpnc:*:|' -i /etc/shadow && \
/usr/bin/ssh-keygen -A && \
echo "vpnc ALL=(ALL) NOPASSWD: /root/init.sh" >> /etc/sudoers && \
apk --purge del apk-tools && \
rm -rf /var/cache/apk/* /var/log/* /var/lib/apt/lists/*

USER vpnc
EXPOSE 22
ENTRYPOINT ["sudo", "/root/init.sh"]
