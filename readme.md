Goal of the project

This assignment has several parts. Parts 1 and 2 deal with the problem of building a VPN-like setup, where two islands of private address space are transparently connected over another network. We will use two different methods to achieve the end result. In part 3, you will analyze BGP routing tables to understand interdomain routing.

Part 1 and 2: Problem definition and setup

Consider the following setup. We have N servers hosted in a private IP address space providing a service. We have N clients also in the same private address space that wish to contact the N servers. However, the clients and servers are not in physical proximity, and are separated by the public Internet. The N servers are all behind a router S, that also has a public IP and connects to the Internet. The N clients are also behind a gateway C that connects to the public network. Your goal is to enable the clients and servers operating in their own private addres space to talk to each other over the public network. This is an abstract problem that VPNs try to solve, and the problem that this programming assignment will get you to solve.

We will create this setup on a smaller scale as described below. You must create a similar setup to test your code as you develop it.

Take two machines (you and your friend can pool in your laptops for example). Call them C and S. Both machines can reach each other over the local CSE LAN, and will have addresses from the 10.129 CSE address space.
On each of C and S, simulate a LAN connection to the private address space of 192.168/16. You can do this in several ways.
Ideally, you take several (physical or virtual) machines, assign them addresses from the 192.168/16 subnet, and connect them via a (physical or virtual) switch to C. Repeat for S. This creates a private LAN in the 192.168/16 address space behind each of C and S. These islands in the 192.168/16 address space must be connected over the CSE LAN (which is a different private address space, but represents the public Internet in our case).
However, since it is difficult to setup and manage many physical / virtual machines, you may simulate the above setup by using temporary virtual interfaces. You can create virtual interfaces using the ifconfig command as follows. For example, suppose machine S has interface eth0 that connects to the local LAN. We then create a virtual interface on S with address 192.168.100.1 as follows.
$ifconfig eth0:1 192.168.100.1
Here the private interface 192.168.100.1 emulates a machine connected to S over another LAN in the 192.168/16 private address space.
We recommend that you use the virtual interface option above. But do keep the big picture (that it emulates a real machine) in mind when you solve the question.
Create private addresses, say, 192.168.100.1, 192.168.100.2,... on a the LAN behind S and 192.168.200.1, 192.168.200.2, ... behind C, using the step above. Since we haven't implemented a solution, you should not be able to connect (say, ping) from 192.168.200.1 to 192.168.100.1 right now. The goal of this assignment is to enable a ping from, say, 192.168.200.1 to 192.168.100.1 via the CSE LAN.
Note: in some corner cases, someone else may be using these private IP prefix 192.168/16 within IITB, so some of your pings may be replied to by another machine on the same IP address. Since there is no way to know and track who else is using this private prefix, if you find you can ping 192.168.100.1 and so on without doing anything else, please go ahead and try some other address from this prefix that is not reachable.

To make things more realistic, you can run some clients and servers on these private addresses, instead of simple ping. If you simulate the private network using physical / virtual machines on C and S, then, you can simply run the client and server (server1 will do) of programming assignment 1 on these virtual machines. They shouldn't be able to communite with each other yet, of course.
On the other hand, if you simulate the private network using virtual interfaces, you need to specifically instruct the client and server to bind to the 192.168/16 address and not the 10.129 CSE LAN address, to be faithful to our setup of running services in the 192.168/16 address space. For this purpose, you may modify your client and server code from Programming assignment 1 to bind to these private addresses. For example, here is a modified client of PA1 called pclient.c. This client takes 3 arguments (its IP address, server IP, server port). The client then binds to the specific IP address provided instead of binding to any IP address of the machine. Note again that we did not care about which local address the clients and servers were bound to earlier in PA1. But now, since we want to simulate clients and servers running the 192.168/16 address space, we explicitly issue a bind command in the socket program to bind them to a specified address. Otherwise, they may simply bind to the 10.129 address of the host and happily connect to each other without you having to solve the programming assignment, which we do not want. Similarly you can use one of your servers also to bind to the specific private IP address you created. For example, on S, you can start the server as follows.
$./server 192.168.100.1 5000
And on C, you can start the client as follows.
$./pclient 192.168.200.1 192.168.100.1 5000
When you run a server on a 192.168.100.1 address above and a client on 192.168.200.1 address above, without doing anything else, of course the client will not be able to chat with the server. As you build solutions in the assignment going forward, your client should be able to chat with the server, like it did in PA1.
Note: if you did not write a correct server1 in PA1, ask one of your friends for the server code. You need not turn in the client and server files used in testing, so you can share the client and server socket program code with your friends for this PA.
Our test setup

In our test setup, we will setup three clients on IPs 192.168.200.1-3 behind C, and three corresponding servers listening on port 5000 on addresses 192.168.100.1-3 behind S. That is, client 192.168.200.1 will connect to server 192.168.100.1 on port 5000, client 192.168.200.2 will connect to server 192.168.100.2 on port 5000, and so on. We will use the clients and servers of programming assignment 1, taking care to see that they bind to the 192.168/16 addresses, as described above.
You will provide scripts that run at C and S in the assignment below, which we will deploy at C and S. We will then check that that the clients and servers can talk to each other, much like they did in PA1. Your solutions should work for at least these 3 connections, of course you are welcome to do more. That is, you can build a generic solution that will work for any server (on any port) running on any 192.168/16 address behind S to talk to any client in the 192.168/16 address behind C. However, in our evaluation, we will test that the three connections described above work fine.
Your solution should work when we use virtual interfaces to simulate machines in the 192/168/16 address space. The description based on physical / virtual machines above was just for your understanding.
You needn't turn in any code you use for the setup (for example, the client and server socket programs that bind to private addresses). We will use our own code for testing.
Our test machines S and C will have IP addresses 10.129.5.193 and 10.129.5.194 from the CSE LAN address space. You can use this information in your final solution that you submit. However, please do not use these addresses of C and S during your tests, because several of you using the same addresses will lead to IP address conflicts. Beware of IP address conflicts. Please work with the DHCP-assigned addresses of C and S from the 10.129 address space. Please use these static addresses of C and S (if needed) only in your final solution that you submit.
Part 1: VPN using IP tables

In this part, you will enable connectivity between the clients and servers in the 192.168/16 address space using a bunch of iptables commands at nodes C and S. You will provide two scripts, "pa3-part1-c.sh" and "pa3-part1-s.sh" that will be run as superuser at C and S respectively. We will setup our clients and servers as described above, then run the scripts provided by you at C and S, and expect the clients and servers to talk to each other after that. It is expected that your scripts are composed mainly of iptables commands.

This link (and many more that can be found via Google) should give you a good overview of iptables.

Our solution to this part has 2 iptables rules at C and 1 rule at S for each TCP connection. Of course, you may have more or less depending on how you approach the problem. However, we mention this so you know that your final solution should only be a handful of rules, if you are on the right track.

Note:If you run into errors, use tcpdump or wireshark to inspect your packet headers, to make sure you have done the correct packet modifications for this assignment.

Part 2: VPN using tunnelling with tun interface

In this part, you will enable connectivity between the clients and servers in the 192.168/16 address space using tunnelling between the machines C and S. The setup of virtual interfaces etc. is the same as in part 1.

This link provides a good tutorial on the use of tun/tap devices, and will help you solve most of this part of the assignment. You can use the source code found in the tutorial to solve the assignment.

Following are the steps to be followed when building a VPN using tunnelling. The tutorial above will explain these steps in much more detail.

First, you will create a tun device at each of C and S, say, using the "openvpn --mktun" command. You may have to install the openvpn package on Ubuntu. Similar packages may exist for other Linux distributions. After creating the tun device, you may have to bring it up, give it an IP address and do other such configuration.
Next, divert all traffic from clients and servers in the 192.168/16 address space to the tun device using a route command for example.
Next, run two socket programs at C and S, that will together tunnel data that comes through the tun device over the CSE LAN using IP-in-IP tunnelling. For example, your code must read from tun device and write to the network device (eth0, say), and must read from network device and write into the tun device. You may tunnel over TCP or UDP. Take care to preserve IP packet boundaries. For example, you must read a full IP packet from the network and write to the tun device, since the tun device will be expecting whole IP packets (much like a real device).
You must submit all the files required to solve the assignment, as well as two top-level scripts that run at C and S: pa3-part2-c.sh, pa3-part2-s.sh. These scripts should do all the steps above (create tun device, setup routes to divert traffic to tun device etc.), including compiling any socket programs and running them. In our test setup, we will only run the top-level scripts at C and S, and check whether the clients and servers in the private address space can communicate with each other. We will not compile or run the socket programs (your scripts must do it).
Part 3: Setup and dataset

Several routing tables are publicly available, for example, from the routeviews project. The BGP router at routeviews peers with several BGP routers in several other organizations, and collects their BGP routing tables and updates. The full routing tables (RIBs) are dumped periodically, and are accessible on the website. Streaming updates from the BGP peers are also archived every few minutes. These routing tables are usually in some specific binary formats for ease of storage and download. To make your life simpler, we have downloaded the routing tables and converted them to an easy to read format using some readily available tools.

Download a zipped up version of a text-format BGP routing table file from here for this assignment. The first line of the routing table is as follows:

TABLE_DUMP2|1408060800|B|85.114.0.217|8492|1.0.0.0/24|8492 15169|IGP|85.114.0.217|0|0|8492:1305 29076:223 29076:900 29076:51003 29076:53003 29076:60495 29076:64667|NAG||
A brief description of the fields is as follows.
The first field indicates the type of dump, and the second is timestamp.
The third field, here "B" indicates that this is a base table. The updates table will have "A" or "W" here indicating announcement and withdrawal of prefixes respectively.
85.114.0.217 and 8492 indicate the IP and AS of the BGP peer in another organization, from whom the routeviews BGP router got the routing table information.
"1.0.0.0/24" is the prefix, and "8492 15169" is the AS path to reach from this prefix from the BGP router in AS8492. (Sometimes the AS path may have sets of ASes (e.g., {1, 2}) when multiple AS paths have been aggregated. You may ignore such AS paths as they will be very few in number.)
You shouldn't need the other fields. In case you are curious, here is the complete schema:
type|time|B_or_A_or_W|from_ip|from_as|prefix|aspath|origin|nexthop|localpref|med|community|atomic_aggregate|agrgegator|
Note: The routing table file is very large. Do not try to open and browse through it using regular editors. You will need to write scripts to answer the following questions.
Part 3: Understanding BGP routing table data

In your report, answer the following questions by analyzing the routing table file provided to you. Briefly describe how you arrive at your answer (don't just provide a final number).

How many IP prefixes does the Internet have? How many unique ASes? (Note: Unless otherwise mentioned, a prefix refers to any prefix that appears in the routing table, even if it is contained in another prefix, overlaps with another prefix etc. That is, count all prefixes even if they do not cover mutually exlusive IP address ranges.)
IITB owns four /24s in the range 103.21.124.0 - 103.21.127.255. List all the routing table entries (prefixes and corresponding AS paths) that correspond to IITB in the routing table.
From the AS path information above, figure out how many ISPs IITB buys network service from. Write down their AS numbers, and names (from looking up whois).
Find out the top 10 ASes that have the highest degree (i.e., connected to the most number of other ASes, as seen from the AS paths) in the routing table. Look up their names from whois. Can you guess what these ASes are (e.g., ISPs, end-user companies etc.) from their names?
