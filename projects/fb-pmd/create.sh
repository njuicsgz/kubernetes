#!/bin/bash

kubectl create -f fbagent-service-rc.json
kubectl create -f mq-services-rc.json
kubectl create -f rdb-rc.json
kubectl create -f scheduler-rc.json
kubectl create -f walle-java-rc.json
