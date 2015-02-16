##1. Docker install in all nodes
    same with another chapter "K8s All-In-One"
##2. Etcd install in master node
'''
    # wget https://github.com/coreos/etcd/releases/download/v2.0.0/etcd-v2.0.0-linux-amd64.tar.gz
    # tar -C /usr/local -xzf etcd-v2.0.0-linux-amd64.tar.gz 
    # mkdir -p /opt/bin
    # cp /usr/local/etcd-v2.0.0-linux-amd64/etcd /opt/bin/
    # export PATH=$PATH:/opt/bin
    # service etcd start <Should start etcd before K8s installation, Or all K8s service will started automatically which is a All-In-One case>
'''
##3. Install K8s by release tar file in master/minions
'''
    # tar xzf kubernetes.tar.gz -C /usr/local/
    # cd /usr/local/kubernetes/server/
    # tar xzf kubernetes-server-linux-amd64.tar.gz
    # cp kubernetes/server/bin/* /opt/bin/
    # cd /usr/local/kubernetes/cluster/ubuntu
    # ./util.sh
'''
    We need to disable auto start of some components by edit conf to comment those two lines (do it in minions only, no need to do this if you did not install etcd in minions):
    kube-apiserver.conf           kube-controller-manager.conf   kube-scheduler.conf 
    '''
    \# vi /etc/init/kube-apiserver.conf
    \# start on started etcd
    \# stop on stopping etcd
    '''
    Add change from 'etcd' to 'docker' for 'kube-proxy' and 'kubelet':
    '''
    start on started docker
    stop on stopping docker

    *So the restart dependency is like this:
    [Master and Minions] docker->etcd->kube-apiserver/kube-controller-manager/kube-scheduler/kube-proxy/kubelet
    [Minions] docker->kube-proxy/kubelet
    
##4. Kube Master Conf
    *4.1 \# cat /etc/default/etcd
    '''
    ETCD_OPTS="-listen-client-urls=http://allen01:4001"
    '''
  
    *4.2 reconfig master conf and start services       
    '''
    root@allen01:~\# cat /etc/default/kube-apiserver 
    KUBE_APISERVER_OPTS="--address=0.0.0.0 \
    --port=8080 \
    --kubelet_port=10250 \
    --etcd_servers=http://172.30.50.78:4001 \
    --logtostderr=true \
    --portal_net=10.0.10.0/24"
    '''
    '''
    root@allen01:~\# cat /etc/default/kube-scheduler 
        KUBE_SCHEDULER_OPTS="--logtostderr=true \
        --master=172.30.50.78:8080"
        
        root@allen01:~\# cat /etc/default/kube-controller-manager 
        KUBE_CONTROLLER_MANAGER_OPTS="--master=172.30.50.78:8080 \
        --machines=172.30.50.87,172.30.50.88,172.30.50.78 \
        --logtostderr=true"
        
        root@allen01:~\# cat /etc/default/kube-proxy   
        KUBE_PROXY_OPTS="--etcd_servers=http://172.30.50.78:4001 \
        --logtostderr=true"
        
        root@allen01:~\# cat /etc/default/kubelet  
        KUBELET_OPTS="--address=172.30.50.78 \
        --port=10250 \
        --hostname_override=172.30.50.78 \
        --etcd_servers=http://172.30.50.78:4001 \
        --logtostderr=true"
        \# service etcd restart   (restart all components of Kube)
    '''
##5. Kube Minior * 2
      root@allen02:~/demo/1+N/netconf\# cat /etc/default/kube-proxy
      KUBE_PROXY_OPTS="--etcd_servers=http://172.30.50.78:4001 \
      --logtostderr=true"

      root@allen02:~/demo/1+N/netconf\# cat /etc/default/kubelet
      KUBELET_OPTS="--address=172.30.50.87 \
      --port=10250 \
      --hostname_override=172.30.50.87 \
      --etcd_servers=http://172.30.50.78:4001 \
      --logtostderr=true"
      
##6.  NetWork environment setup
'''
root@allen01:~/demo/1+N/netconf\# cat ovs-conf.sh 
\#!/bin/bash
\# Name of the bridge
BRIDGE_NAME=docker0
\# Bridge address
BRIDGE_ADDRESS=10.244.1.1/24

\# Deactivate the docker0 bridge
ip link set $BRIDGE_NAME down
\# Remove the docker0 bridge
brctl delbr $BRIDGE_NAME
\# Delete the Open vSwitch bridge
ovs-vsctl del-br br0
\# Add the docker0 bridge
brctl addbr $BRIDGE_NAME
\# Set up the IP for the docker0 bridge
ip a add $BRIDGE_ADDRESS dev $BRIDGE_NAME
\# Add the br0 Open vSwitch bridge
ovs-vsctl add-br br0
\# Create the tunnel to the other host and attach it to the
\# br0 bridge
ovs-vsctl add-port br0 gre2 -- set interface gre2 type=gre options:remote_ip=172.30.50.87
ovs-vsctl add-port br0 gre3 -- set interface gre3 type=gre options:remote_ip=172.30.50.88
\# Add the br0 bridge to docker0 bridge
brctl addif $BRIDGE_NAME br0

ovs-vsctl set bridge br0 stp_enable=true

ip link set dev docker0 up
ip link set dev br0 up

\#ip route 
ip route add 10.244.2.0/24 via 172.30.50.87
ip route add 10.244.3.0/24 via 172.30.50.88

\# iptables rules
 
\# Enable NAT
\#iptables -t nat -A POSTROUTING -s 10.244.0.0/16 ! -d 10.244.0.0/16 -j MASQUERADE
\# Accept incoming packets for existing connections
\#iptables -A FORWARD -o docker0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
\# Accept all non-intercontainer outgoing packets
\#iptables -A FORWARD -i docker0 ! -o docker0 -j ACCEPT
\# By default allow all outgoing traffic
\#iptables -A FORWARD -i docker0 -o docker0 -j ACCEPT
 
\# Restart Docker daemon to use the new BRIDGE_NAME
service docker restart

\# Some useful commands to confirm the settings:
\# ip a s
\# ip r s
\# ovs-vsctl show
\# brctl show
'''
'''
root@allen02:~/demo/1+N/netconf\# cat ovs-conf.sh 
\#!/bin/bash

\# Name of the bridge
BRIDGE_NAME=docker0
\# Bridge address
BRIDGE_ADDRESS=10.244.2.1/24

\#Other nodes
IP_NODE1=172.30.50.78
IP_NODE3=172.30.50.88

\# Deactivate the docker0 bridge
ip link set $BRIDGE_NAME down
\# Remove the docker0 bridge
brctl delbr $BRIDGE_NAME
\# Delete the Open vSwitch bridge
ovs-vsctl del-br br0
\# Add the docker0 bridge
brctl addbr $BRIDGE_NAME
\# Set up the IP for the docker0 bridge
ip a add $BRIDGE_ADDRESS dev $BRIDGE_NAME
\# Add the br0 Open vSwitch bridge
ovs-vsctl add-br br0
\# Create the tunnel to the other host and attach it to the
\# br0 bridge
ovs-vsctl add-port br0 gre1 -- set interface gre1 type=gre options:remote_ip=$IP_NODE1
ovs-vsctl add-port br0 gre3 -- set interface gre3 type=gre options:remote_ip=$IP_NODE3
\# Add the br0 bridge to docker0 bridge
brctl addif $BRIDGE_NAME br0

ovs-vsctl set bridge br0 stp_enable=true
ip link set dev docker0 up
ip link set dev br0 up

\#ip route 
ip route add 10.244.1.0/24 via $IP_NODE1
ip route add 10.244.3.0/24 via $IP_NODE3

\# iptables rules
 
\# Enable NAT
\#iptables -t nat -A POSTROUTING -s 10.244.0.0/16 ! -d 10.244.0.0/16 -j MASQUERADE
\# Accept incoming packets for existing connections
\#iptables -A FORWARD -o docker0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
\# Accept all non-intercontainer outgoing packets
\#iptables -A FORWARD -i docker0 ! -o docker0 -j ACCEPT
\# By default allow all outgoing traffic
\#iptables -A FORWARD -i docker0 -o docker0 -j ACCEPT
 
\# Restart Docker daemon to use the new BRIDGE_NAME
service docker restart

\# Some useful commands to confirm the settings:
\# ip a s
\# ip r s
\# ovs-vsctl show
\# brctl show
'''
'''
root@allen03:~/demo/1+N/netconf\# cat ovs-conf.sh 
\#!/bin/bash

\# Name of the bridge
BRIDGE_NAME=docker0
\# Bridge address
BRIDGE_ADDRESS=10.244.3.1/24

\# Deactivate the docker0 bridge
ip link set $BRIDGE_NAME down
\# Remove the docker0 bridge
brctl delbr $BRIDGE_NAME
\# Delete the Open vSwitch bridge
ovs-vsctl del-br br0
\# Add the docker0 bridge
brctl addbr $BRIDGE_NAME
\# Set up the IP for the docker0 bridge
ip a add $BRIDGE_ADDRESS dev $BRIDGE_NAME
\# Add the br0 Open vSwitch bridge
ovs-vsctl add-br br0
\# Create the tunnel to the other host and attach it to the
\# br0 bridge
ovs-vsctl add-port br0 gre2 -- set interface gre2 type=gre options:remote_ip=172.30.50.87
ovs-vsctl add-port br0 gre1 -- set interface gre1 type=gre options:remote_ip=172.30.50.78
\# Add the br0 bridge to docker0 bridge
brctl addif $BRIDGE_NAME br0

ovs-vsctl set bridge br0 stp_enable=true

ip link set dev docker0 up
ip link set dev br0 up

\#ip route 
ip route add 10.244.1.0/24 via 172.30.50.78
ip route add 10.244.2.0/24 via 172.30.50.87


\# iptables rules
 
\# Enable NAT
\#iptables -t nat -A POSTROUTING -s 172.16.42.0/24 ! -d 172.16.42.0/24 -j MASQUERADE
\# Accept incoming packets for existing connections
\#iptables -A FORWARD -o docker0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
\# Accept all non-intercontainer outgoing packets
\#iptables -A FORWARD -i docker0 ! -o docker0 -j ACCEPT
\# By default allow all outgoing traffic
\#iptables -A FORWARD -i docker0 -o docker0 -j ACCEPT
 
\# Restart Docker daemon to use the new BRIDGE_NAME
service docker restart

\# Some useful commands to confirm the settings:
\# ip a s
\# ip r s
\# ovs-vsctl show
\# brctl show
   \# ./ovs-conf.sh <run in all nodes to setup network and restart kube/docker/etcd services>
'''
*Currently, you could verify network by ping:
root@allen01:~\# ping 10.244.2.1
root@allen01:~\# ping 10.244.3.1

##7. Demo
*7.1 Web service with 2 backends deployment
    \# kubectl create -f web-rc.json
    \# kubectl create -f web-service.json
root@allen01:~/demo/1+N\# cat web-rc.json                   
{  
  "id": "webservercontroller",  
  "kind": "ReplicationController",  
  "apiVersion": "v1beta1",  
  "labels": {"name": "webserver"},  
  "desiredState": {  
    "replicas": 2,  
    "replicaSelector": {"name": "webserver_pod"},  
    "podTemplate": {  
      "desiredState": {  
         "manifest": {  
           "version": "v1beta1",  
           "id": "webserver",  
           "containers": [{  
             "name": "webserver",  
             "image": "allen01:5000/tutum/apache-php",  
             "command": ["/bin/sh", "-c", "/run.sh"],  
             "ports": [{  
                "hostPort": 10080,
               "containerPort": 80,  
            }]  
           }]  
         }  
       },  
       "labels": {"name": "webserver_pod"},  
      },  
  }  
}  
root@allen01:~/demo/1+N\# cat web-service.json                  
{  
  "id": "webserver",  
  "kind": "Service",  
  "apiVersion": "v1beta1",  
  "selector": {  
    "name": "webserver_pod",  
  },  
  "protocol": "TCP",  
  "containerPort": 80,  
  "port": 40080  
}  

Verify that all pods are created successfully:
root@allen01:~/demo/1+N\# kubectl get services
NAME                LABELS                                    SELECTOR             IP                  PORT
kubernetes          component=apiserver,provider=kubernetes   <none>               172.17.0.2          443
kubernetes-ro       component=apiserver,provider=kubernetes   <none>               172.17.0.1          80
webserver           <none>                                    name=webserver_pod   10.0.10.53         40080
root@allen01:~/demo/1+N\# kubectl get replicationControllers
CONTROLLER            CONTAINER(S)        IMAGE(S)                        SELECTOR             REPLICAS
webservercontroller   webserver           allen01:5000/tutum/apache-php   name=webserver_pod   2
root@allen01:~/demo/1+N\# kubectl get pods
POD                         IP                  CONTAINER(S)        IMAGE(S)                        HOST       LABELS               STATUS
webservercontroller-ls6k1   10.244.2.17         webserver           allen01:5000/tutum/apache-php   172.30.50.87/172.30.50.87   name=webserver_pod   Running
webservercontroller-oh43e   10.244.3.3          webserver           allen01:5000/tutum/apache-php   172.30.50.88/172.30.50.88   name=webserver_pod   Running

\# curl http://10.0.10.53:40080
\# curl http://10.244.3.3:80
\# iptables -nvL -t nat
\# curl 172.30.50.78:51450

*7.2 Auto recovery
1) Kill docker instance
root@allen02:~\# docker ps
CONTAINER ID        IMAGE                                  COMMAND                CREATED             STATUS              PORTS                   NAMES
d05fbb9f874f        allen01:5000/tutum/apache-php:latest   "/bin/sh -c /run.sh"   About an hour ago   Up About an hour                            k8s_webserver.f530a0cb_webservercontroller-ls6k1.default.etcd_818baa78-b0cd-11e4-9a9c-000c29883b2b_474e8ed4   
e17cd01ee5b0        kubernetes/pause:go                    "/pause"               About an hour ago   Up About an hour    0.0.0.0:10080->80/tcp   k8s_POD.b14fdf6f_webservercontroller-ls6k1.default.etcd_818baa78-b0cd-11e4-9a9c-000c29883b2b_592229f5         
root@allen02:~\# docker kill d05fbb9f874f
d05fbb9f874f
root@allen02:~\# docker ps
CONTAINER ID        IMAGE                 COMMAND             CREATED             STATUS       PORTS                   NAMES
e17cd01ee5b0        kubernetes/pause:go   "/pause"            About an hour ago   Up About an hour    0.0.0.0:10080->80/tcp   k8s_POD.b14fdf6f_webservercontroller-ls6k1.default.etcd_818baa78-b0cd-11e4-9a9c-000c29883b2b_592229f5   
root@allen02:~\# docker ps
CONTAINER ID        IMAGE                                  COMMAND                CREATED             STATUS              PORTS                   NAMES
d03d5b94c417        allen01:5000/tutum/apache-php:latest   "/bin/sh -c /run.sh"   2 seconds ago       Up 1 seconds                                k8s_webserver.f530a0cb_webservercontroller-ls6k1.default.etcd_818baa78-b0cd-11e4-9a9c-000c29883b2b_e2c60430   
e17cd01ee5b0        kubernetes/pause:go                    "/pause"               About an hour ago   Up About an hour    0.0.0.0:10080->80/tcp   k8s_POD.b14fdf6f_webservercontroller-ls6k1.default.etcd_818baa78-b0cd-11e4-9a9c-000c29883b2b_592229f5
2) delete pod
root@allen01:~/demo/1+N\# kubectl get pods
POD                         IP                  CONTAINER(S)        IMAGE(S)                        HOST       LABELS               STATUS
webservercontroller-ls6k1   10.244.2.17         webserver           allen01:5000/tutum/apache-php   172.30.50.87/172.30.50.87   name=webserver_pod   Running
webservercontroller-oh43e   10.244.3.3          webserver           allen01:5000/tutum/apache-php   172.30.50.88/172.30.50.88   name=webserver_pod   Running
root@allen01:~/demo/1+N\# kubectl delete pod webservercontroller-ls6k1
webservercontroller-ls6k1
root@allen01:~/demo/1+N\# kubectl get pods
POD                         IP                  CONTAINER(S)        IMAGE(S)                        HOST       LABELS               STATUS
webservercontroller-fplln   10.244.1.2          webserver           allen01:5000/tutum/apache-php   172.30.50.78/172.30.50.78   name=webserver_pod   Running
webservercontroller-oh43e   10.244.3.3          webserver           allen01:5000/tutum/apache-php   172.30.50.88/172.30.50.88   name=webserver_pod   Running

*7.3 Load balance by service
1) Access service by VIP and port, it will go to back end by RoundRobin
root@allen01:~/demo/1+N\# kubectl get pods
POD                         IP                  CONTAINER(S)        IMAGE(S)                        HOST       LABELS               STATUS
webservercontroller-fplln   10.244.1.2          webserver           allen01:5000/tutum/apache-php   172.30.50.78/172.30.50.78   name=webserver_pod   Running
webservercontroller-oh43e   10.244.3.3          webserver           allen01:5000/tutum/apache-php   172.30.50.88/172.30.50.88   name=webserver_pod   Running
root@allen01:~/demo/1+N\# kubectl get services
NAME                LABELS                                    SELECTOR             IP                  PORT
kubernetes          component=apiserver,provider=kubernetes   <none>               172.17.0.2          443
kubernetes-ro       component=apiserver,provider=kubernetes   <none>               172.17.0.1          80
webserver           <none>                                    name=webserver_pod   10.0.10.53         40080
root@allen01:~/demo/1+N\# curl 10.0.10.53:40080
        <h2>My hostname is: webservercontroller-fplln</h2>      <h2>My IP is: 10.244.1.2</h2>
        
root@allen01:~/demo/1+N\# curl 10.0.10.53:40080
        <h2>My hostname is: webservercontroller-oh43e</h2>      <h2>My IP is: 10.244.3.3</h2> 
