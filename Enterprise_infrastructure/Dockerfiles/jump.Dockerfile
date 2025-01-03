# Description: Dockerfile for the jump server
# How you can start this container, read README.md

# Use the official Ubuntu image as the base image
FROM ubuntu:latest

# Set the default shell 
SHELL ["/bin/sh", "-c"]

# Install necessary packages
RUN apt-get update && apt-get install -y iptables nano openssh-server

# Add user 'jump' with password 'password'
RUN useradd -m jump && echo "jump:password" | chpasswd
#RUN usermod -s /bin/bash jump

# Expose port 22 for SSH
EXPOSE 22

# Check if user 'jump' exists, if not, create it
RUN id -u jump &>/dev/null || useradd -m jump

# Configure SSH server
RUN mkdir -p /run/sshd /var/run/sshd && \
    sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config && \
    echo "AllowTcpForwarding yes" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config &&\
    echo "AllowUsers jump" >> /etc/ssh/sshd_config

RUN service ssh start

# Start the SSH services and keep the container running
CMD ["sh", "-c", "service ssh start && exec tail -f /dev/null"]