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

# Backup the existing rules in user home directory
bash -c "iptables-save > $HOME/iptables.bak"
bash -c "ip6tables-save > $HOME/ip6tables.bak"

# Set default policies to accept (IPv4)
/sbin/iptables -P INPUT ACCEPT
/sbin/iptables -P FORWARD ACCEPT
/sbin/iptables -P OUTPUT ACCEPT

# Flush all the existing iptables rules (IPv4)
/sbin/iptables -t nat -F
/sbin/iptables -t mangle -F
/sbin/iptables -F
/sbin/iptables -X

# Set default policies to accept (IPv6)
#/sbin/ip6tables -P INPUT ACCEPT
#/sbin/ip6tables -P FORWARD ACCEPT
#/sbin/ip6tables -P OUTPUT ACCEPT

# Flush all the existing iptables rules (IPv6)
#/sbin/ip6tables -t nat -F
#/sbin/ip6tables -t mangle -F
#/sbin/ip6tables -F
#/sbin/ip6tables -X

# Allow current SSH connection
/sbin/iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
#/sbin/ip6tables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Keep SSH (default 22) and Web Server (default 80) ports open
/sbin/iptables -A INPUT -p tcp --dport 22 -j ACCEPT
#/sbin/ip6tables -A INPUT -p tcp --dport 22 -j ACCEPT

/sbin/iptables -A INPUT -p tcp --dport 80 -j ACCEPT
#/sbin/ip6tables -A INPUT -p tcp --dport 80 -j ACCEPT

# Allow connections from a loopback device
/sbin/iptables -I INPUT 1 -i lo -j ACCEPT
#/sbin/ip6tables -I INPUT 1 -i lo -j ACCEPT

########## Custom Rules Start ##########

# Allow IPs in the list to connect
# IPs are stored in a file name iplist

# Get IPs separated by a comma
allowedips=$(cat iplist | tr -s '\n' ',')
# Remove the last comma
allowedips=$(echo "$allowedips" | sed 's/.$//')

# Insert accept connection rule for the IP list at line 5
/sbin/iptables -I INPUT 5 -s "$allowedips" -j ACCEPT
#/sbin/ip6tables -I INPUT 4 new_rule_here

########### Custom Rules End ###########

# Append drop rule to drop all the connections not satisfied by above rules
/sbin/iptables -A INPUT -j DROP
#/sbin/ip6tables -A INPUT -j DROP

# Save the rules at proper locations
bash -c "/sbin/iptables-save > /etc/iptables/rules.v4"
#bash -c "/sbin/ip6tables-save > /etc/iptables/rules.v6"

# Restart and enable netfilter-persistent service
# 'enable' makes the service start automatically on startup (boot)
systemctl restart netfilter-persistent.service
systemctl enable netfilter-persistent.service

exit 0
