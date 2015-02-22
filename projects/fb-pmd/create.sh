#!/bin/bash

kubecfg ns facebook-pmd
kubectl create -f fbagent-service-rc.json
kubectl create -f mq-services-rc.json
kubectl create -f rdb-rc.json
kubectl create -f scheduler-rc.json
kubectl create -f walle-java-rc.json
#kubectl create -f walle-java-svc.json
kubectl create -f dubbo-monitor-svc-rc.json
kubectl create -f dubbo-monitor-svc-svc.json
kubectl create -f dubbo-monitor-web-rc.json
kubectl create -f dubbo-monitor-web-svc.json
kubectl create -f config-rc.json
kubectl create -f config-svc.json
kubectl create -f walle-web-rc.json
kubectl create -f walle-web-svc.json
