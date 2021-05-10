FROM alpine:latest

# https://docs.docker.com/engine/examples/running_ssh_service/

RUN \
apk update && \
apk add --no-cache openssh-server nano networkmanager vpnc && \
sed -E 's|^#?AllowTcpForwarding.*|AllowTCPForwarding yes|g' -i /etc/ssh/sshd_config && \
sed -E 's|^#?ChallengeResponseAuthentication.*|ChallengeResponseAuthentication no|g' -i /etc/ssh/sshd_config && \
sed -E 's|^#?PasswordAuthentication.*|PasswordAuthentication no|g' -i /etc/ssh/sshd_config

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

COPY config/default.conf /etc/vpnc/default.conf
COPY config/init.sh /root/init.sh
RUN chmod +x /root/init.sh

RUN \
adduser --disabled-password --home /home/vpnc vpnc && \
mkdir -p /home/vpnc/.ssh

COPY config/authorized_keys /home/vpnc/.ssh

RUN \
chmod 600 /home/vpnc/.ssh/authorized_keys && \
chown vpnc:vpnc -R /home/vpnc/.ssh

# https://unix.stackexchange.com/a/170871/235763
RUN sed 's|^vpnc:!:|vpnc:*:|' -i /etc/shadow

RUN /usr/bin/ssh-keygen -A

EXPOSE 22
CMD ["/root/init.sh"]
