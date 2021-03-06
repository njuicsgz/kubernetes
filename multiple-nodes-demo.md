##1. Docker install in all nodes
If you have ubuntu14.04 with kernel 3.13:
https://docs.docker.com/installation/ubuntulinux/#ubuntu-trusty-1404-lts-64-bit
```
# sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
# curl -sSL https://get.docker.com/ubuntu/ | sudo sh
```
##2. Etcd install in master node
```
# root@pdm-165:~/paas/setup# curl -L  https://github.com/coreos/etcd/releases/download/v2.0.5/etcd-v2.0.5-linux-amd64.tar.gz
# tar -C /usr/local -xzf etcd-v2.0.5-linux-amd64.tar.gz 
# mkdir -p /opt/bin/
# cp /usr/local/etcd-v2.0.5-linux-amd64/etcd /opt/bin/
# export PATH=$PATH:/opt/bin/
# etcd --listen-client-urls=http://172.30.10.165:4001 --data-dir=/root/etcd-data > /dev/null 2>&1 &
```
##3. Install K8s by release tar file in master
```
# tar xzf kubernetes.tar.gz -C /usr/local/
# cd /usr/local/kubernetes/server/
# tar xzf kubernetes-server-linux-amd64.tar.gz
# cp kubernetes/server/bin/* /opt/bin/

# cd /usr/local/kubernetes/cluster/ubuntu
# cp initd_scripts/* /etc/init.d/
# cp default_scripts/* /etc/default/
# cp init_conf/* /etc/init
```
And scp all needed files to minions from master
```
# scp /opt/bin/kubelet /opt/bin/kube-proxy root@172.30.10.166:/opt/bin/
# scp /etc/default/kubelet /etc/default/kube-proxy  root@172.30.10.166:/etc/default/
# scp /etc/init.d/kubelet /etc/init.d/kube-proxy   root@172.30.10.166:/etc/init.d/
# scp /etc/init/kube-proxy.conf  /etc/init/kubelet.conf    root@172.30.10.166:/etc/init/
```

## 4. Kube Master Conf
* 4.2 reconfig master conf and start services       
    ```
# cat /etc/default/kube-apiserver 
KUBE_APISERVER_OPTS="--address=0.0.0.0 \
--v=0 \
--port=8080 \
#--tls_cert_file=/root/github/kubernetes/demo/Auth/ssl-cert/server.crt \
#--tls_private_key_file=/root/github/kubernetes/demo/Auth/ssl-cert/server.key \
#--authorization_mode=ABAC \
#--token_auth_file=/root/github/kubernetes/demo/Auth/known_tokens.csv \
#--authorization_policy_file=/root/github/kubernetes/demo/Auth/authz_policy.json \
--kubelet_port=10250 \
--etcd_servers=http://172.30.10.122:4001 \
--logtostderr=true \
--runtime_config=api/v1beta3 \
#--admission_control=NamespaceExists,LimitRanger,ResourceQuota \
--portal_net=10.55.0.0/24"
# service kube-apiserver start
```
```
# cat /etc/default/kube-scheduler 
  KUBE_SCHEDULER_OPTS="--logtostderr=true \
  --master=172.30.50.78:8080"
# service kube-scheduler start
```
```
# cat /etc/default/kube-controller-manager 
  KUBE_CONTROLLER_MANAGER_OPTS="--master=172.30.50.78:8080 \
  --machines=172.30.50.87,172.30.50.88,172.30.50.78 \
  --logtostderr=true"
# service kube-controller-manager start
```
```
# cat /etc/default/kube-proxy   
    KUBE_PROXY_OPTS="--master==172.30.50.78:8080 \
   --logtostderr=true"
# service kube-proxy start
```
```
root@allen01:~\# cat /etc/default/kubelet
   KUBELET_OPTS="--address=0.0.0.0 \
   --port=10250 \
   --hostname_override=172.30.50.78 \
   --api_servers=172.30.50.78:8080 \
   #--etcd_servers=http://172.30.50.78:4001 \ use api_servers instead of etcd_servicers for ver>0.12.0
   --logtostderr=true"
# service kubelet start
```

##5. Kube Minior * 2
```
  root@allen02:~/demo/1+N/netconf\# cat /etc/default/kube-proxy
  KUBE_PROXY_OPTS="--master==172.30.50.78:8080 \
  --logtostderr=true"

  root@allen02:~/demo/1+N/netconf\# cat /etc/default/kubelet
  KUBELET_OPTS="--address=172.30.50.87 \
  --port=10250 \
  --hostname_override=172.30.50.87 \
  --api_servers=172.30.50.78:8080 \
  #--etcd_servers=http://172.30.50.78:4001 \ use api_servers instead of etcd_servicers for ver>0.12.0
  --logtostderr=true"
```

##6.  NetWork environment setup
### Tips:
目前尝试了两种Docker网络配置方法：
* 用flannel配置 （通过flannel配置Docker网络）建议采用flannel模式。
* 下面script采用OpenVSwitch (不建议)

OVS的缺点是需要手动为每个Docker节点指定IP；建立与其它节点俩俩相通的gre通道，N*(N-1)；当有新的节点进来的时候，需要改动所有已有的配置。
flannel利用etcd采用集中式的机制进行自动化IP配置；增加新节点不改动已有节点的配置；天生支持访问外网，无需手动配置iptables nat；

```
root@allen01:~/demo/1+N/netconf# cat ovs-conf.sh 
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
 
# Enable NAT
iptables -t nat -A POSTROUTING -s 10.244.0.0/16 ! -d 10.244.0.0/16 -j MASQUERADE
# Accept incoming packets for existing connections
iptables -A FORWARD -o docker0 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
# Accept all non-intercontainer outgoing packets
iptables -A FORWARD -i docker0 ! -o docker0 -j ACCEPT
# By default allow all outgoing traffic
iptables -A FORWARD -i docker0 -o docker0 -j ACCEPT
 
# Restart Docker daemon to use the new BRIDGE_NAME
service docker restart

# Some useful commands to confirm the settings:
# ip a s
# ip r s
# ovs-vsctl show
# brctl show
```
```
root@allen02:~/demo/1+N/netconf# cat ovs-conf.sh 
#!/bin/bash

# Name of the bridge
BRIDGE_NAME=docker0
# Bridge address
BRIDGE_ADDRESS=10.244.2.1/24

#Other nodes
IP_NODE1=172.30.50.78
IP_NODE3=172.30.50.88

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
ovs-vsctl add-port br0 gre1 -- set interface gre1 type=gre options:remote_ip=$IP_NODE1
ovs-vsctl add-port br0 gre3 -- set interface gre3 type=gre options:remote_ip=$IP_NODE3
# Add the br0 bridge to docker0 bridge
brctl addif $BRIDGE_NAME br0

ovs-vsctl set bridge br0 stp_enable=true
ip link set dev docker0 up
ip link set dev br0 up

#ip route 
ip route add 10.244.1.0/24 via $IP_NODE1
ip route add 10.244.3.0/24 via $IP_NODE3

# iptables rules
 
# Enable NAT
#iptables -t nat -A POSTROUTING -s 10.244.0.0/16 ! -d 10.244.0.0/16 -j MASQUERADE
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
```
```
root@allen03:~/demo/1+N/netconf# cat ovs-conf.sh 
#!/bin/bash

# Name of the bridge
BRIDGE_NAME=docker0
# Bridge address
BRIDGE_ADDRESS=10.244.3.1/24

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
ovs-vsctl add-port br0 gre1 -- set interface gre1 type=gre options:remote_ip=172.30.50.78
# Add the br0 bridge to docker0 bridge
brctl addif $BRIDGE_NAME br0

ovs-vsctl set bridge br0 stp_enable=true

ip link set dev docker0 up
ip link set dev br0 up

#ip route 
ip route add 10.244.1.0/24 via 172.30.50.78
ip route add 10.244.2.0/24 via 172.30.50.87


# iptables rules
 
# Enable NAT
#iptables -t nat -A POSTROUTING -s 172.16.42.0/24 ! -d 172.16.42.0/24 -j MASQUERADE
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
 
# ./ovs-conf.sh <run in all nodes to setup network and restart kube/docker/etcd services>
```
* Currently, you could verify network by ping:
 
root@allen01:~# ping 10.244.2.1
root@allen01:~# ping 10.244.3.1


## 7. Demo
### 7.1 Web service with 2 backends deployment
```
# kubectl create -f web-rc.json
# kubectl create -f web-service.json
```

```
root@allen01:~/demo/1+N# cat web-rc.json                   
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
root@allen01:~/demo/1+N# cat web-service.json                  
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
```

* Verify that all pods are created successfully:
```
root@allen01:~/demo/1+N# kubectl get services
NAME                LABELS                                    SELECTOR             IP                  PORT
kubernetes          component=apiserver,provider=kubernetes   <none>               172.17.0.2          443
kubernetes-ro       component=apiserver,provider=kubernetes   <none>               172.17.0.1          80
webserver           <none>                                    name=webserver_pod   10.0.10.53         40080
root@allen01:~/demo/1+N# kubectl get replicationControllers
CONTROLLER            CONTAINER(S)        IMAGE(S)                        SELECTOR             REPLICAS
webservercontroller   webserver           allen01:5000/tutum/apache-php   name=webserver_pod   2
root@allen01:~/demo/1+N# kubectl get pods
POD                         IP                  CONTAINER(S)        IMAGE(S)                        HOST       LABELS               STATUS
webservercontroller-ls6k1   10.244.2.17         webserver           allen01:5000/tutum/apache-php   172.30.50.87/172.30.50.87   name=webserver_pod   Running
webservercontroller-oh43e   10.244.3.3          webserver           allen01:5000/tutum/apache-php   172.30.50.88/172.30.50.88   name=webserver_pod   Running

# curl http://10.0.10.53:40080
# curl http://10.244.3.3:80
# iptables -nvL -t nat
# curl 172.30.50.78:51450
```

### 7.2 Auto recovery
* 1) Kill docker instance
```
root@allen02:~# docker ps
CONTAINER ID        IMAGE                                  COMMAND                CREATED             STATUS              PORTS                   NAMES
d05fbb9f874f        allen01:5000/tutum/apache-php:latest   "/bin/sh -c /run.sh"   About an hour ago   Up About an hour                            k8s_webserver.f530a0cb_webservercontroller-ls6k1.default.etcd_818baa78-b0cd-11e4-9a9c-000c29883b2b_474e8ed4   
e17cd01ee5b0        kubernetes/pause:go                    "/pause"               About an hour ago   Up About an hour    0.0.0.0:10080->80/tcp   k8s_POD.b14fdf6f_webservercontroller-ls6k1.default.etcd_818baa78-b0cd-11e4-9a9c-000c29883b2b_592229f5         
root@allen02:~# docker kill d05fbb9f874f
d05fbb9f874f
root@allen02:~# docker ps
CONTAINER ID        IMAGE                 COMMAND             CREATED             STATUS       PORTS                   NAMES
e17cd01ee5b0        kubernetes/pause:go   "/pause"            About an hour ago   Up About an hour    0.0.0.0:10080->80/tcp   k8s_POD.b14fdf6f_webservercontroller-ls6k1.default.etcd_818baa78-b0cd-11e4-9a9c-000c29883b2b_592229f5   

root@allen02:~# docker ps
CONTAINER ID        IMAGE                                  COMMAND                CREATED             STATUS              PORTS                   NAMES
d03d5b94c417        allen01:5000/tutum/apache-php:latest   "/bin/sh -c /run.sh"   2 seconds ago       Up 1 seconds                                k8s_webserver.f530a0cb_webservercontroller-ls6k1.default.etcd_818baa78-b0cd-11e4-9a9c-000c29883b2b_e2c60430   
e17cd01ee5b0        kubernetes/pause:go                    "/pause"               About an hour ago   Up About an hour    0.0.0.0:10080->80/tcp   k8s_POD.b14fdf6f_webservercontroller-ls6k1.default.etcd_818baa78-b0cd-11e4-9a9c-000c29883b2b_592229f5
```
* 2) delete pod
```
root@allen01:~/demo/1+N# kubectl get pods
POD                         IP                  CONTAINER(S)        IMAGE(S)                        HOST       LABELS               STATUS
webservercontroller-ls6k1   10.244.2.17         webserver           allen01:5000/tutum/apache-php   172.30.50.87/172.30.50.87   name=webserver_pod   Running
webservercontroller-oh43e   10.244.3.3          webserver           allen01:5000/tutum/apache-php   172.30.50.88/172.30.50.88   name=webserver_pod   Running
root@allen01:~/demo/1+N# kubectl delete pod webservercontroller-ls6k1
webservercontroller-ls6k1
root@allen01:~/demo/1+N# kubectl get pods
POD                         IP                  CONTAINER(S)        IMAGE(S)                        HOST       LABELS               STATUS
webservercontroller-fplln   10.244.1.2          webserver           allen01:5000/tutum/apache-php   172.30.50.78/172.30.50.78   name=webserver_pod   Running
webservercontroller-oh43e   10.244.3.3          webserver           allen01:5000/tutum/apache-php   172.30.50.88/172.30.50.88   name=webserver_pod   Running
```

### 7.3 Load balance by service
* 1) Access service by VIP and port, it will go to back end by RoundRobin
```
root@allen01:~/demo/1+N# kubectl get pods
POD                         IP                  CONTAINER(S)        IMAGE(S)                        HOST       LABELS               STATUS
webservercontroller-fplln   10.244.1.2          webserver           allen01:5000/tutum/apache-php   172.30.50.78/172.30.50.78   name=webserver_pod   Running
webservercontroller-oh43e   10.244.3.3          webserver           allen01:5000/tutum/apache-php   172.30.50.88/172.30.50.88   name=webserver_pod   Running

root@allen01:~/demo/1+N# kubectl get services
NAME                LABELS                                    SELECTOR             IP                  PORT
kubernetes          component=apiserver,provider=kubernetes   <none>               172.17.0.2          443
kubernetes-ro       component=apiserver,provider=kubernetes   <none>               172.17.0.1          80
webserver           <none>                                    name=webserver_pod   10.0.10.53         40080

root@allen01:~/demo/1+N# curl 10.0.10.53:40080
  My hostname is: webservercontroller-fplln      My IP is: 10.244.1.2
   
root@allen01:~/demo/1+N# curl 10.0.10.53:40080
   My hostname is: webservercontroller-oh43e      My IP is: 10.244.3.3 
```
