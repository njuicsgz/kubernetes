#!/bin/bash

kubectl config set current-context my-context
kubectl config set-context my-context --namespace=paas

kubectl create -f registry-rc.json
sleep 10 
kubectl create -f registry-svc.json
sleep 2
kubectl create -f registry-proxy-rc.json
kubectl create -f registry-proxy-svc.json
kubectl create -f registry-gui-rc.json
kubectl create -f registry-gui-svc.json
