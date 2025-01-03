#!/bin/bash

# Activate IP redirect
echo 1 > /proc/sys/net/ipv4/ip_forward

# Set iptables rules for NAT (enterprise_net)
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i eth0 -o eth1 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT

# Save the rules
apt-get update -y && apt-get install -y iptables-persistent
netfilter-persistent save
netfilter-persistent reload