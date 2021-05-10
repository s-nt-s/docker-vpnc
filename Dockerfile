FROM alpine:latest

# https://docs.docker.com/engine/examples/running_ssh_service/
# https://unix.stackexchange.com/a/170871/235763

RUN \
apk update && \
apk add --no-cache openssh-server vpnc && \
sed -E 's|^#?AllowTcpForwarding.*|AllowTCPForwarding yes|g' -i /etc/ssh/sshd_config && \
sed -E 's|^#?ChallengeResponseAuthentication.*|ChallengeResponseAuthentication no|g' -i /etc/ssh/sshd_config && \
sed -E 's|^#?PasswordAuthentication.*|PasswordAuthentication no|g' -i /etc/ssh/sshd_config && \
adduser --disabled-password --home /home/vpnc vpnc && \
mkdir -p /home/vpnc/.ssh

COPY config/default.conf /etc/vpnc/default.conf
COPY config/init.sh /root/init.sh
COPY config/authorized_keys /home/vpnc/.ssh

RUN \
chmod +x /root/init.sh && \
chmod 600 /home/vpnc/.ssh/authorized_keys && \
chown vpnc:vpnc -R /home/vpnc/.ssh && \
sed 's|^vpnc:!:|vpnc:*:|' -i /etc/shadow && \
/usr/bin/ssh-keygen -A

EXPOSE 22
CMD ["/root/init.sh"]
