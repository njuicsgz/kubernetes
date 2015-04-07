Setup etcd cluster of 3 nodes with version：v2.0.5:

node1:10.1.35.50
```
root@AMZ-IAD-WallE-35-50:~/paas/script# cat etcd-restart.sh 
#! /bin/bash
export PATH=/sbin:/usr/sbin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin

# stop
killall etcd

# start
MY_ADDR=http://10.1.35.50
PEER_ADDR1=http://10.1.35.51
PEER_ADDR2=http://10.1.35.52

cd  /root/paas/bin/etcd/v2.0.5 || exit
nohup ./etcd -name infra0 -initial-advertise-peer-urls ${MY_ADDR}:2380 \
      -listen-peer-urls ${MY_ADDR}:2380 \
      -listen-client-urls=${MY_ADDR}:2379,http://127.0.0.1:4001 \
      -data-dir=/root/paas/etcd-data \
      -initial-cluster-token etcd-cluster-1 \
      -initial-cluster infra0=${MY_ADDR}:2380,infra1=${PEER_ADDR1}:2380,infra2=${PEER_ADDR2}:2380 \
      -initial-cluster-state new > /dev/null 2>&1 &
```
node2:10.1.35.51
```
root@AMZ-IAD-WallE-35-51:~/paas/script# cat etcd-restart.sh 
#! /bin/bash                                                                                                                        
export PATH=/sbin:/usr/sbin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin

# stop
killall etcd

# start
MY_ADDR=http://10.1.35.51
PEER_ADDR1=http://10.1.35.50
PEER_ADDR2=http://10.1.35.52

cd  /root/paas/bin/etcd/v2.0.5 || exit
nohup ./etcd -name infra1 -initial-advertise-peer-urls ${MY_ADDR}:2380 \
    -listen-peer-urls ${MY_ADDR}:2380 \
    -listen-client-urls=${MY_ADDR}:2379 \
    -data-dir=/root/paas/etcd-data \
    -initial-cluster-token etcd-cluster-1 \
    -initial-cluster infra0=${MY_ADDR}:2380,infra1=${PEER_ADDR1}:2380,infra2=${PEER_ADDR2}:2380 \
    -initial-cluster-state new > /dev/null 2>&1 &
```
* node3: 10.1.35.52
```
root@AMZ-IAD-WallE-35-52:~/paas/script# cat etcd-restart.sh 
#! /bin/bash                                                                                                                        
export PATH=/sbin:/usr/sbin:/usr/local/sbin:/usr/local/bin:/usr/bin:/bin

# stop
killall etcd

# start
MY_ADDR=http://10.1.35.52
PEER_ADDR1=http://10.1.35.50
PEER_ADDR2=http://10.1.35.51

cd  /root/paas/bin/etcd/v2.0.5 || exit
nohup ./etcd -name infra2 -initial-advertise-peer-urls ${MY_ADDR}:2380 \
    -listen-peer-urls ${MY_ADDR}:2380 \
    -listen-client-urls=${MY_ADDR}:2379 \
    -data-dir=/root/paas/etcd-data \
    -initial-cluster-token etcd-cluster-1 \
    -initial-cluster infra0=${MY_ADDR}:2380,infra1=${PEER_ADDR1}:2380,infra2=${PEER_ADDR2}:2380 \
    -initial-cluster-state new > /dev/null 2>&1 &
```
