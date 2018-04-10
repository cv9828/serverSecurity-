#!/bin/bash

# Description: Clears all the existing iptables rules
#              Creates rules to allow my and IPs in the list, dropping others
#
# Usage      : ./ips.sh
#				 iptables -L -v 
#				 ip6tables -L -v
#
#				 apt-get install iptables-persistent


allowedips=""

# Backup the existing rules
iptables-save > iptables.bak
ip6tables-save > ip6tables.bak

# Clear all the existing iptables rules
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
iptables -t nat -F
iptables -t mangle -F
iptables -t raw -F
iptables -t raw -X
iptables -F
iptables -X
# Clear all the existing ip6tables rules
ip6tables -P INPUT ACCEPT
ip6tables -P FORWARD ACCEPT
ip6tables -P OUTPUT ACCEPT
ip6tables -t nat -F
ip6tables -t mangle -F
ip6tables -t raw -F
ip6tables -t raw -X
ip6tables -F
ip6tables -X
# Block all except my IP
iptables -I INPUT ! -s myIP -j DROP

# Allow IPs in the list
while read ip
do
    allowedips="$allowedips"$(echo -n "$ip ")
done < iplist

echo ""

iptables -A INPUT -s $allowedips -j ACCEPT

# Save the rules
bash -c "iptables-save > /etc/iptables/rules.v4"
bash -c "ip6tables-save > /etc/iptables/rules.v6"

# Start and enable the service for the next boot
systemctl start netfilter-persistent.service
systemctl enable netfilter-persistent.service

exit 0
