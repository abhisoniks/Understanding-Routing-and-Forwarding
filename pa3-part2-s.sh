openvpn --mktun --dev tun0
ip link set tun0 up
ip addr add 192.168.100.1/16 dev tun0
./simpletun -i tun0 -s

