#!/bin/bash

allowedips=""

echo "Do we need to remove existing rules?"
echo ""
echo "Blocking all except my IP:"
echo ""
#echo "iptables -I INPUT -p tcp ! -s yourIPaddress --dport 22 -j DROP"
echo "iptables -I INPUT ! -s myIP -j DROP"
echo ""

while read ip
do
    allowedips="$allowedips"$(echo -n "$ip ")
done < iplist

echo ""

echo "Allow IPs in a list:"
echo ""
echo "iptables -A INPUT -s $allowedips -j ACCEPT"
echo ""
echo "Save the rules based on the distro"
