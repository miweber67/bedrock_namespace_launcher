# https://cloudnull.io/2019/04/running-services-in-network-name-spaces-with-systemd/


# Server #
NUMBER=1

# Choose a block of IP addresses that your DHCP server will NOT hand out
# to use for your bedrock servers. For example, this test assumes
# 192.168.1.61 will be used, by combining "192.168.1.6" with the server
# number, 1: "192.168.1.6" + "1" = "192.168.1.61"
ADDRESS=192.168.1.6${NUMBER}

#activate ipv4 routing
sudo sysctl -w net.ipv4.ip_forward=1

# create network namespace
sudo ip netns delete bds_net_${NUMBER}
sudo ip netns add bds_net_${NUMBER}
# does thislo up need to be done here, and also later?
sudo ip netns exec bds_net_${NUMBER} ip link set lo up

sudo ip link add mv-int link enp5s0 type macvlan mode bridge
sudo ip link set mv-int up

# Is there a reason this link is created and moved to the netns in different steps?
# Pivot link
sudo ip link add mv0 link mv-int type macvlan mode bridge
sudo ip link set mv0 netns bds_net_${NUMBER} name mv${NUMBER}
# Configure link
# does this lo up need to be done here, and also earlier?
sudo ip netns exec bds_net_${NUMBER} ip link set lo up
sudo ip netns exec bds_net_${NUMBER} ip link set dev mv${NUMBER} up
#sudo ip netns exec bds_net_1 ip address add 172.22.23.60/24 dev mv0
sudo ip netns exec bds_net_${NUMBER} ip address add ${ADDRESS}/24 dev mv${NUMBER}
#sudo ip route add 172.22.23.60/32 dev mv-int metric 100 table local
sudo ip route add ${ADDRESS}/32 dev mv-int metric 100 table local

sudo ip netns exec bds_net_${NUMBER} sysctl -w net.ipv4.conf.mv${NUMBER}.forwarding=1
sudo ip netns exec bds_net_${NUMBER} sysctl -w net.ipv4.conf.mv${NUMBER}.arp_notify=1
sudo ip netns exec bds_net_${NUMBER} sysctl -w net.ipv4.conf.mv${NUMBER}.arp_announce=2
sudo ip netns exec bds_net_${NUMBER} sysctl -w net.ipv4.conf.mv${NUMBER}.use_tempaddr=0

# If you do not have the setuidgid tool, you should install daemontools.
# If you can't install daemontools, you can still run the server as root
# but THIS IS A SECURITY RISK.
# sudo ip netns exec bds_net_${NUMBER} ./bedrock_server

# It is also recommended to create an unprivileged user separate from
# your main accounts to host the servers. This way if the server is
# remotely compromised, the attacker does not start out with privileges
# that can be used to harm your machine right away.
sudo ip netns exec bds_net_${NUMBER} setuidgid bds ./bedrock_server

