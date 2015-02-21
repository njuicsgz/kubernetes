#!/bin/bash

kubecfg ns facebook-pmd
kubectl create -f fbagent-service-rc.json
kubectl create -f mq-services-rc.json
kubectl create -f rdb-rc.json
kubectl create -f scheduler-rc.json
kubectl create -f walle-java-rc.json
kubectl create -f walle-java-svc.json
