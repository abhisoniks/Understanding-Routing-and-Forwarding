iptables -t nat -A POSTROUTING -p tcp -d 10.129.5.193  -j MASQUERADE
iptables -t nat -A OUTPUT -p tcp -s 192.168.200.1 -d 192.168.100.1  -j DNAT --to-destination 10.129.5.193:6000
iptables -t nat -A OUTPUT -p tcp -s 192.168.200.2 -d 192.168.100.2  -j DNAT --to-destination 10.129.5.193:6001
iptables -t nat -A OUTPUT -p tcp -s 192.168.200.3 -d 192.168.100.3  -j DNAT --to-destination 10.129.5.193:6002
