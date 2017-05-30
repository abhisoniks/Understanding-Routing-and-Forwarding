openvpn --mktun --dev tun1
ip link set tun1 up
ip addr add 192.168.200.1/16 dev tun1
./simpletun -i tun1 -c 10.129.5.193




