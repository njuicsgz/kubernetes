#!/bin/bash

kubectl config set current-context my-context
kubectl config set-context my-context --namespace=fb-pmd-allen
#kubecfg ns fb-pmd-allen
kubectl create -f fb-ns.json
kubectl create -f zk-rc.json 
kubectl create -f zk-svc.json 

echo "ZK is crated."
sleep 15

kubectl create -f config-rc.json
kubectl create -f config-svc.json
echo "creating configuration center..."
sleep 15
echo "you MUST to push all config to ZK before starting other components. And you have 1min to operate this."

sleep 60 
kubectl create -f fbagent-service-rc.json
kubectl create -f mq-services-rc.json
kubectl create -f rdb-rc.json
kubectl create -f scheduler-rc.json
kubectl create -f walle-java-rc.json
kubectl create -f walle-java-svc.json
kubectl create -f dubbo-monitor-svc-rc.json
kubectl create -f dubbo-monitor-svc-svc.json
kubectl create -f dubbo-monitor-web-rc.json
kubectl create -f dubbo-monitor-web-svc.json
kubectl create -f walle-web-rc.json
kubectl create -f walle-web-svc.json
