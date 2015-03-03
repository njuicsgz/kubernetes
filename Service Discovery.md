##问题：
当我们通过ReplicationController创建了一组同构的Pod，并通过Service把它们组织起来的时候，有那些途径可以获取到这个Service？

##实例：
* 创建文件：https://github.com/njuicsgz/kubernetes/tree/master/demo/1%2BN
```
root@allen01:~/github/kubernetes/demo/1+N# kubectl get pod
POD                         IP                  CONTAINER(S)        IMAGE(S)                        HOST                        LABELS               STATUS
webservercontroller-h3x9k   10.10.85.10         webserver           allen01:5000/tutum/apache-php   172.30.50.87/172.30.50.87   name=webserver_pod   Running
webservercontroller-pjzb3   10.10.91.11         webserver           allen01:5000/tutum/apache-php   172.30.50.88/172.30.50.88   name=webserver_pod   Running
root@allen01:~/github/kubernetes/demo/1+N# kubectl get service
NAME                LABELS                                    SELECTOR             IP                  PORT
kubernetes          component=apiserver,provider=kubernetes   <none>               172.17.0.2          443
kubernetes-ro       component=apiserver,provider=kubernetes   <none>               172.17.0.1          80
webserver           <none>                                    name=webserver_pod   10.0.10.145         40080
```

##访问方式：
###在K8s系统内部（任何Minions）：
* 1.1 通过Pod内部IP和端口： # curl 10.10.85.10:80
* 1.2 通过Service IP和端口：# curl 10.0.10.145:40080 （支持Load balance）

###在K8s系统外部和内部：
* 2.1 通过Pod所在Host的IP和端口：# curl 172.30.50.87:10080
* 2.2 通过Service 映射本地NAT IP和端口：# curl 172.30.50.87:42594 （支持Load balance，随机端口）
```
root@allen02:~# iptables -nvL -t nat
 pkts bytes target     prot opt in     out     source               destination   
    1    60 DNAT       tcp  --  !docker0 *       0.0.0.0/0            0.0.0.0/0            tcp dpt:10080 to:10.10.85.10:80

Chain KUBE-PORTALS-CONTAINER (1 references)
 pkts bytes target     prot opt in     out     source               destination  
    0     0 REDIRECT   tcp  --  *      *       0.0.0.0/0            10.0.10.145          /* webserver */ tcp dpt:40080 redir ports 42594
    0     0 REDIRECT   tcp  --  *      *       0.0.0.0/0            172.30.50.78         /* webserver */ tcp dpt:40080 redir ports 42594
    6   312 REDIRECT   tcp  --  *      *       0.0.0.0/0            172.30.50.87         /* webserver */ tcp dpt:40080 redir ports 42594

Chain KUBE-PORTALS-HOST (1 references)
 pkts bytes target     prot opt in     out     source               destination    
    0     0 DNAT       tcp  --  *      *       0.0.0.0/0            10.0.10.145          /* webserver */ tcp dpt:40080 to:172.30.50.87:42594
    0     0 DNAT       tcp  --  *      *       0.0.0.0/0            172.30.50.78         /* webserver */ tcp dpt:40080 to:172.30.50.87:42594
    0     0 DNAT       tcp  --  *      *       0.0.0.0/0            172.30.50.87         /* webserver */ tcp dpt:40080 to:172.30.50.87:42594
```
* 2.3 通过Service publicIPs访问： http://172.30.50.78:40080 or http://172.30.50.87:40080 （支持LB，固定端口）
* 2.4 通过Proxy（例如Ngnix）将Public IP上的服务转发给Service 内网IP，（支持LB，固定端口），需要一台具有外部IP的Host，配置同K8s系统相同的网络（比如通过flannel）。
 
##缺点与演进：
* 2.3 的缺点在于：1）它只能复用有限的public IP，这些IPs是Minions的所有public IP；2）一个需要Expose端口的Service会尽可能多地设置publicIPs，理想情况下是所有的Minions公用IPs，理由是如果我们的Service下面有4个后端，但只配置了一个publicIP，那么当这个IP所在的Minion挂掉后，外部将不能访问这个服务（内部依然可以）。那么，对于同一个端口的服务数量就有最大数的限制N（N为Minions的数量），虽然这种方式已经能满足绝大多数需求，但是还是一些有想法的人还是提供了更为宽松的解决方式：
http://blog.oddbit.com/2015/02/10/external-networking-for-kubernetes-services/。 使用插件Kiwi为每一个需要Expose的Service提供一个或多个单独的Public IP。

* 另外官方对此也有一些讨论（https://github.com/GoogleCloudPlatform/kubernetes/issues/1161），解决方法是将Service/Pod标记为'External'，通过External的Port来访问，而非External的IP，这些方式需要IaaS Provider的参与，类似GCE的createExternalLoadBalancer 。
