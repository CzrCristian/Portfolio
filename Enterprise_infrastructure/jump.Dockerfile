# Description: Dockerfile for the jump server
# How you can start this container:
#    docker build -f jump.Dockerfile -t jump .
#    docker run -d -p 27022:22 --name jump jump
#    docker exec -it jump /bin/bash


# Use the official Ubuntu image as the base image
FROM ubuntu:latest

# Install necessary packages
RUN apt-get update && apt-get install -y iptables nano postfix openssh-server mailutils

# Configure and enable Postfix service
RUN echo "relayhost = [smtp.example.com]:587" >> /etc/postfix/main.cf && \
    echo "smtp_sasl_auth_enable = yes" >> /etc/postfix/main.cf && \
    echo "smtp_sasl_password_maps = static:jump@example.com:password" >> /etc/postfix/main.cf && \
    echo "smtp_sasl_security_options = noanonymous" >> /etc/postfix/main.cf && \
    echo "smtp_tls_security_level = encrypt" >> /etc/postfix/main.cf && \
    echo "smtp_tls_note_starttls_offer = yes" >> /etc/postfix/main.cf && \
    systemctl enable postfix

# Configure SSH server
RUN sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config && \
    echo "AllowTcpForwarding yes" >> /etc/ssh/sshd_config

# Check if user 'jump' exists, if not, create it
RUN id -u jump &>/dev/null || useradd -m jump

# Expose port 22 for SSH
EXPOSE 22

# Set the health check to run every hour using a ping command and send an email if it fails
HEALTHCHECK --interval=1h CMD ping -c 1 8.8.8.8 || (echo "[server_status] Health check failed" | mail -s "Health Check Alert" jump@example.com)

# Start the SSH and Postfix services
CMD /bin/sh -c "service postfix start && /usr/sbin/sshd -D"

# Set the default shell 
SHELL ["/bin/sh", "-c"]
# Send an email to user 'jump' with the start date and time
RUN echo "Serverul Jump a pornit la data $(date '+%d.%m.%Y %H:%M:%S')." | mail -s "[server_status] Started" jump@example.com