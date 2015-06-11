## Ref:
https://github.com/GoogleCloudPlatform/kubernetes/blob/master/docs/accessing_the_api.md
https://github.com/GoogleCloudPlatform/kubernetes/blob/master/docs/authorization.md
https://github.com/GoogleCloudPlatform/kubernetes/blob/master/docs/authentication.md
https://github.com/erictune/kubernetes/blob/2a8cc9a3a7726d9efe11b083d1cc4d63ed070f4b/docs/access.md
https://github.com/jlowdermilk/kubernetes/blob/de76486aa04509a341526bd54395366c28ee38bb/docs/kubeconfig-file.md

##1. 配置SSL证书
###1. 生成SSL证书
```
  openssl req -x509 -newkey rsa:4086 \
  -subj "/C=XX/ST=XXXX/L=XXXX/O=XXXX/CN=dev.k8s.paas.ndp.com" \
  -keyout "key.pem" \
  -out "cert.pem" \
  -days 3650 -nodes -sha256
```
自认证：
###
```
# cat cert.pem  >> /etc/ssl/certs/ca-certificates.crt 
```

##2. 配置ApiServer
```
root@allen01:~# vi /etc/default/kube-apiserver 
KUBE_APISERVER_OPTS="--address=0.0.0.0 \
--v=2 \
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
--portal_net=10.0.10.0/24"

root@allen01:~/github/kubernetes/demo/Auth# cat authz_policy.json 
{"user":"admin"}
{"user":"fb", "namespace":"facebook-pmd"}
{"user":"fb-r", "readonly":true, "namespace":"facebook-pmd"}
{"user":"fb-r-pod", "readonly": true, "namespace": "facebook-pmd", "resource": "pods"}
{"user":"test", "namespace":"test"}
{"user":"none-exist", "namespace":"none-exist-ns"}
root@allen01:~/github/kubernetes/demo/Auth# cat known_tokens.csv
myToken0,admin,8888
myToken1,none-exist,1000
myToken2,fb-r,1001
myToken3,fb-r-pod,1002
myToken4,fb,1003
myToken5,test,1004
root@allen01:~/github/kubernetes/demo/Auth# service kube-apiserver restart
kube-apiserver stop/waiting
kube-apiserver start/running, process 116632
```
* So you can access by curl like this:
root@paas-186:~# curl  --header "Authorization: Bearer myToken0" --cacert ~/.kubecfg.crt https://k8s.paas.ndp.com:6443/api/v1beta/namespaces/

##3. 配置 .kubernetes_auth
```
# cp ca.crt ~/.kubernetes.ca.crt
# cp server.key ~/.kubecfg.key
# cp server.crt ~/.kubecfg.crt

root@allen01:~# cat .kubernetes_auth 
{
  "CAFile": "/root/.kubernetes.ca.crt",
  "CertFile": "/root/.kubecfg.crt",
  "KeyFile": "/root/.kubecfg.key",
  "BearerToken": "secrettoken"
}

root@allen01:~# ll | grep kube
-rw-r--r--  1 root root  1306 Feb 25 10:13 .kubecfg.crt
-rw-r--r--  1 root root  1679 Feb 25 10:14 .kubecfg.key
-rw-r--r--  1 root root  1424 Feb 25 10:14 .kubernetes.ca.crt
-rw-r--r--  1 root root   146 Feb 26 02:01 .kubernetes_auth
-rw-------  1 root root    20 Feb 26 03:03 .kubernetes_ns
drwxr-xr-x  7 root root  4096 Feb  3 12:53 kubernetes/
```

##4. Demo
###4.1 非认证的token不能访问任何资源
```
root@allen01:~/github/kubernetes/demo/1+N# kubectl get pod --server=https://k8s.paas.ndp.com:6443 --token=myToken-x --namespace=facebook-pmd  
F0226 08:04:17.351595  116786 get.go:166] request [&{Method:GET URL:https://k8s.paas.ndp.com:6443/api/v1beta1/pods?namespace=facebook-pmd Proto:HTTP/1.1 ProtoMajor:1 ProtoMinor:1 Header:map[] Body:<nil> ContentLength:0 TransferEncoding:[] Close:false Host:k8s.paas.ndp.com:6443 Form:map[] PostForm:map[] MultipartForm:<nil> Trailer:map[] RemoteAddr: RequestURI: TLS:<nil>}] failed (401) 401 Unauthorized: Unauthorized
```

###4.3 所有权用户具有所有权限-Admin
```
root@allen01:~/github/kubernetes/demo/1+N# kubectl create -f web-service.json --server=https://k8s.paas.ndp.com:6443 --token=myToken12 --namespace=test webserver
root@allen01:~/github/kubernetes/demo/1+N# kubectl delete -f web-service.json --server=https://k8s.paas.ndp.com:6443 --token=myToken12 --namespace=test
webserver
```

###4.4 只读用户不具有写操作权限-Read Only
```
root@allen01:~/github/kubernetes/demo/1+N# kubectl create -f web-service.json --server=https://k8s.paas.ndp.com:6443 --token=myToken2 --namespace=facebook-pmd          
F0226 06:54:21.765921  105520 create.go:78] request [&{Method:POST URL:https://k8s.paas.ndp.com:8443/api/v1beta1/services?namespace=facebook-pmd Proto:HTTP/1.1 ProtoMajor:1 ProtoMinor:1 Header:map[] Body:{Reader:} ContentLength:239 TransferEncoding:[] Close:false Host:k8s.paas.ndp.com:8443 Form:map[] PostForm:map[] MultipartForm:<nil> Trailer:map[] RemoteAddr: RequestURI: TLS:<nil>}] failed (403) 403 Forbidden: Forbidden: "/api/v1beta1/services?namespace=facebook-pmd"
```
###4.5 namespace域的用户可以操作NS资源
```
root@allen01:~/github/kubernetes/demo/1+N# kubectl create -f web-service.json --server=https://k8s.paas.ndp.com:6443 --token=myToken4 --namespace=facebook-pmd
webserver
root@allen01:~/github/kubernetes/demo/1+N# kubectl delete -f web-service.json --server=https://k8s.paas.ndp.com:6443 --token=myToken4 --namespace=facebook-pmd
webserver
```
### 4.6 NS内用户可以操作其它NS资源（bug？）
* Comments: this problem is resolved by changing "ns" to "namespace" in the policy json file. 
https://github.com/GoogleCloudPlatform/kubernetes/issues/6752
```
root@allen01:~/github/kubernetes/demo/1+N# kubectl create -f web-service.json --server=https://k8s.paas.ndp.com:6443 --token=myToken4 --namespace=test
webserver
root@allen01:~/github/kubernetes/demo/1+N# kubectl get service --server=https://k8s.paas.ndp.com:6443 --token=myToken4 --namespace=test               NAME                LABELS              SELECTOR             IP                  PORT
webserver           <none>              name=webserver_pod   10.0.10.10          40080
root@allen01:~/github/kubernetes/demo/1+N# kubectl delete -f web-service.json --server=https://k8s.paas.ndp.com:6443 --token=myToken4 --namespace=test 
webserver
```
##总结：
* 1. 认证比较简单、没什么问题
* 2. 鉴权需要配置到文件中，增加、修改配置需要重启服务
