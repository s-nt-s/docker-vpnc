FROM ubuntu:18.04

# https://docs.docker.com/engine/examples/running_ssh_service/

RUN apt-get update
RUN apt-get install -y openssh-server nano network-manager network-manager-vpnc curl
RUN mkdir /var/run/sshd

# SSH login fix. Otherwise user is kicked off after login
RUN sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

COPY config/default.conf /etc/vpnc/default.conf
COPY config/init.sh /root/init.sh
RUN chmod +x /root/init.sh

RUN useradd -ms /bin/bash vpnc
RUN mkdir -p /home/vpnc/.ssh
COPY config/authorized_keys /home/vpnc/.ssh
RUN chmod 600 /home/vpnc/.ssh/authorized_keys
RUN chown vpnc:vpnc -R /home/vpnc/.ssh

EXPOSE 22
CMD ["/root/init.sh"]
