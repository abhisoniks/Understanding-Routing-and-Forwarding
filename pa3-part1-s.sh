iptables -t nat -A PREROUTING -p tcp -s 10.129.5.194 -d 10.129.5.193 --dport 6000 -j  DNAT --to-destination 192.168.100.1:5000
iptables -t nat -A PREROUTING -p tcp -s 10.129.5.194 -d 10.129.5.193 --dport 6001 -j  DNAT --to-destination 192.168.100.2:5000
iptables -t nat -A PREROUTING -p tcp -s 10.129.5.194 -d 10.129.5.193 --dport 6002 -j  DNAT --to-destination 192.168.100.3:5000
