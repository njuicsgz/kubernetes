#!/bin/bash

killall flanneld
killall docker

service etcd restart
flanneld -etcd-endpoints=http://allen01:4001 > /dev/null 2>&1 &
sleep 1
source /run/flannel/subnet.env
ip link del docker0
docker -d --bip=${FLANNEL_SUBNET} --mtu=${FLANNEL_MTU}  > /dev/null 2>&1 &
