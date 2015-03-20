#!/bin/bash

killall flanneld
killall docker

service etcd restart
iptables -t nat -F
flanneld -etcd-endpoints=http://allen01:4001 > /dev/null 2>&1 &
sleep 3 
source /run/flannel/subnet.env
ip link del docker0
docker -d --bip=${FLANNEL_SUBNET} --mtu=${FLANNEL_MTU} --insecure-registry allen01:5000 > /dev/null 2>&1 &

service kubelet restart
service kube-proxy restart
