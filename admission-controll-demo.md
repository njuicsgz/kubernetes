##策略：
Controll Adminssion是在用户认证、鉴权之后的另一层访问控制。目前主要策略主要有：
* 以Container、Pod为单位的，对CPU、Memory资源请求的控制：LimitRanger
* 以namespace为单位的，对CPU、Memory、service、pod、rc数量的请求控制：ResourceQuota

##Demo：
###1. ApiServer Config：
```
root@allen01:~/github/kubernetes/demo/limitrange# cat /etc/default/kube-apiserver 
KUBE_APISERVER_OPTS="--address=0.0.0.0 \
--v=0 \
--port=8080 \
--tls_cert_file=/root/github/kubernetes/demo/Auth/ssl-cert/server.crt \
--tls_private_key_file=/root/github/kubernetes/demo/Auth/ssl-cert/server.key \
--authorization_mode=ABAC \
--token_auth_file=/root/github/kubernetes/demo/Auth/known_tokens.csv \
--authorization_policy_file=/root/github/kubernetes/demo/Auth/authz_policy.json \
--kubelet_port=10250 \
--etcd_servers=http://172.30.50.78:4001 \
--logtostderr=true \
--runtime_config=api/v1beta3 \
--admission_control=NamespaceExists,LimitRanger,ResourceQuota \
--portal_net=10.0.10.0/24"
```
###2. LimitRanger
```
root@allen01:~/github/kubernetes/demo/limitrange# ls
invalid.json  limit-range.json  valid.json
root@allen01:~/github/kubernetes/demo/limitrange# cat limit-range.json 
{
  "apiVersion": "v1beta3",
  "kind": "LimitRange",
  "metadata": {
    "name": "my-limits",
    "namespace": "facebook-pmd"
  },
  "spec": {
    "limits": [
    {
      "type": "Pod",
      "max": {
        "memory": "2Gi",
        "cpu": "2",
      },
      "min": {
        "memory": "1Mi",
        "cpu": "250m"
      }
    },
    {
      "type": "Container",
      "max": {
        "memory": "2Gi",
        "cpu": "2",
      },
      "min": {
        "memory": "1Mi",
        "cpu": "250m"
      }
    },
    ],
  }
}

root@allen01:~/github/kubernetes/demo/limitrange# cat invalid.json 
{
   "kind":"ReplicationController",
   "apiVersion":"v1beta3",
   "metadata":{
      "name":"mq-service",
      "labels":{
         "name":"mq-service"
      }
   },
   "spec":{
      "replicas": 1,
      "selector":{
         "name":"mq-service"
      },
      "template":{
         "metadata":{
            "labels":{
               "name":"mq-service"
            }
         },
         "spec":{
            "containers":[
               {
                  "name":"mq-service",
                  "image":"allen01:5000/facebook_pmd/mq-services",
                  "ports":[
                  ]
               }
            ]
         }
      }
   }
}
root@allen01:~/github/kubernetes/demo/limitrange# cat valid.json 
{
   "kind":"ReplicationController",
   "apiVersion":"v1beta3",
   "metadata":{
      "namespace": "facebook-pmd",
      "name":"mq-service",
      "labels":{
         "name":"mq-service"
      }
   },
   "spec":{
      "replicas": 1,
      "selector":{
         "name":"mq-service"
      },
      "template":{
         "metadata":{
            "namespace": "facebook-pmd",
            "labels":{
               "name":"mq-service"
            }
         },
         "spec":{
            "containers":[
               {
                  "name":"mq-service",
                  "image":"allen01:5000/facebook_pmd/mq-services",
                  "resources": {
                       "limits": {
                            "cpu": "1",
                            "memory": "1Gi",
                        }
                  },
                  "ports":[
                  ]
               }
            ]
         }
      }
   }
}

root@allen01:~/github/kubernetes/demo/limitrange# kubectl create -f limit-range.json
root@allen01:~/github/kubernetes/demo/limitrange# kubectl get limits
NAME
my-limits
root@allen01:~/github/kubernetes/demo/limitrange# kubectl describe limits my-limits          
Name:           my-limits
Type            Resource        Min     Max
----            --------        ---     ---
Pod             cpu             250m    2
Pod             memory          1Mi     2Gi
Container       cpu             250m    2
Container       memory          1Mi     2Gi

root@allen01:~/github/kubernetes/demo/limitrange# kubectl create -f invalid.json 
mq-service
root@allen01:~/github/kubernetes/demo/limitrange# tail /var/log/upstart/kube-controller-manager.log
E0227 07:18:32.025940   79084 replication_controller.go:91] unable to create pod replica: pods "" is forbidden: Minimum CPU usage per pod is 250m, but requested 0m
E0227 07:18:36.177883   79084 replication_controller.go:91] unable to create pod replica: pods "" is forbidden: Minimum CPU usage per pod is 250m, but requested 0m
```
###3. ResourceQuota
```
root@allen01:~/github/kubernetes/demo/resourcequota# cat resource-quota.json 
{
  "apiVersion": "v1beta3",
  "kind": "ResourceQuota",
  "metadata": {
    "namespace": "facebook-pmd",
    "name": "my-quota",
  },
  "spec": {
    "hard": {
      "memory": "200Gi",
      "cpu": "200",
      "pods": "1",
      "services": "5",
      "replicationcontrollers":"20",
      "resourcequotas":"1",
    },
  }
}

root@allen01:~/github/kubernetes/demo/resourcequota# kubectl create -f resource-quota.json --namespace=facebook-pmd
my-quota

root@allen01:~/github/kubernetes/demo/resourcequota# kubectl describe resourcequota my-quota  --namespace=facebook-pmd
Name:                   my-quota
Resource                Used    Hard
--------                ----    ----
cpu                     1       200
memory                  1Gi     200Gi
pods                    1       1
replicationcontrollers  1       20
resourcequotas          1       1
services                0       5

root@allen01:~/github/kubernetes/demo/limitrange# kubectl get rc,pod
POD                 IP                  CONTAINER(S)        IMAGE(S)                                HOST                        LABELS              STATUS              CREATED
mq-service-zdrpp    10.10.85.44         mq-service          allen01:5000/facebook_pmd/mq-services   172.30.50.87/172.30.50.87   name=mq-service     Running             28 seconds
CONTROLLER          CONTAINER(S)        IMAGE(S)                                SELECTOR            REPLICAS
mq-service          mq-service          allen01:5000/facebook_pmd/mq-services   name=mq-service     4

root@allen01:~/github/kubernetes/demo/limitrange# tail /var/log/upstart/kube-controller-manager.log
E0227 08:29:06.263520   79084 replication_controller.go:91] unable to create pod replica: pods "" is forbidden: Limited to 1 pods
E0227 08:29:16.274280   79084 replication_controller.go:91] unable to create pod replica: pods "" is forbidden: Limited to 1 pods
```
