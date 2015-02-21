#!/bin/bash

kubecfg ns facebook-pmd
kubectl resize replicationController rdb-service --replicas=0
kubectl resize replicationController mq-service --replicas=0
kubectl resize replicationController fbagent-service --replicas=0
kubectl resize replicationController scheduler --replicas=0
kubectl resize replicationController walle-java --replicas=0

sleep 3 

kubectl delete replicationController mq-service
kubectl delete replicationController fbagent-service
kubectl delete replicationController scheduler
kubectl delete replicationController walle-java
kubectl delete replicationController rdb-service
kubectl delete service walle-java
