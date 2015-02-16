## Reference:
* https://coreos.com/docs/distributed-configuration/etcd-api/
* https://github.com/coreos/flannel

## 1. flannel install on all docker hosts
```
# sudo apt-get install linux-libc-dev
# git clone https://github.com/coreos/flannel.git
# cd flannel; ./build
# cp bin/flanneld /opt/bin/
# cp bin/flanneld /usr/bin
```

## 2. flannel config in etcd
```
root@allen01:~# cat flannel_set.txt 
{
    "Network": "10.10.0.0/16",
    "SubnetLen": 24,
    "SubnetMin": "10.10.0.0",
    "SubnetMax": "10.10.254.0",
    "Backend": {
        "Type": "udp",
        "Port": 7890
    }
}
root@allen01:~# curl -L http://172.30.50.78:4001/v2/keys/coreos.com/network/config -XPUT --data-urlencode value@flannel_set.txt
root@allen01:~# curl -L http://172.30.50.78:4001/v2/keys/coreos.com/network/subnets/SubnetLen -XPUT -d value=24
```

## 3. run in all docker hosts
```
root@allen01:~/flannel/bin# flanneld -etcd-endpoints=http://allen01:4001 > /dev/null 2>&1 &
root@allen01:~# source /run/flannel/subnet.env
root@allen01:~# cat  /runnen/flal/subnet.env      
FLANNEL_SUBNET=10.10.18.1/24
FLANNEL_MTU=1472
FLANNEL_IPMASQ=false
root@allen01:~# killall docker
root@allen01:~# ip link del docker0
root@allen01:~# docker -d --bip=${FLANNEL_SUBNET} --mtu=${FLANNEL_MTU}
```

## 4. Verify
*4.1 Containers of differrent host can ping each other
*4.2 Containers has route to access public IP, e.g. ping qq.com







