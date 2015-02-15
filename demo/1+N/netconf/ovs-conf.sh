#!/bin/bash

# Name of the bridge
BRIDGE_NAME=docker0
# Bridge address
BRIDGE_ADDRESS=10.244.1.1/24

# Deactivate the docker0 bridge
ip link set $BRIDGE_NAME down
# Remove the docker0 bridge
brctl delbr $BRIDGE_NAME
# Delete the Open vSwitch bridge
ovs-vsctl del-br br0
# Add the docker0 bridge
brctl addbr $BRIDGE_NAME
# Set up the IP for the docker0 bridge
ip a add $BRIDGE_ADDRESS dev $BRIDGE_NAME
# Add the br0 Open vSwitch bridge
ovs-vsctl add-br br0
# Create the tunnel to the other host and attach it to the
# br0 bridge
ovs-vsctl add-port br0 gre2 -- set interface gre2 type=gre options:remote_ip=172.30.50.87
ovs-vsctl add-port br0 gre3 -- set interface gre3 type=gre options:remote_ip=172.30.50.88
# Add the br0 bridge to docker0 bridge
brctl addif $BRIDGE_NAME br0

ovs-vsctl set bridge br0 stp_enable=true

ip link set dev docker0 up
ip link set dev br0 up

#ip route 
ip route add 10.244.2.0/24 via 172.30.50.87
ip route add 10.244.3.0/24 via 172.30.50.88


# iptables rules
 
# Enable NAT, let containers access public website
iptables -t nat -A POSTROUTING -s 10.244.0.0/16 ! -d 10.244.0.0/16 -j MASQUERADE
# Accept incoming packets for existing connections
#iptables -A FORWARD -o docker0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
# Accept all non-intercontainer outgoing packets
#iptables -A FORWARD -i docker0 ! -o docker0 -j ACCEPT
# By default allow all outgoing traffic
#iptables -A FORWARD -i docker0 -o docker0 -j ACCEPT
 
# Restart Docker daemon to use the new BRIDGE_NAME
service docker restart

# Some useful commands to confirm the settings:
# ip a s
# ip r s
# ovs-vsctl show
# brctl show
