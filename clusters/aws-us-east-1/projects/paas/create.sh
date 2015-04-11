#!/bin/bash

kubectl config set current-context my-context
kubectl config set-context my-context --namespace=paas

kubectl create -f registry-rc.json
kubectl create -f registry-svc.json
kubectl create -f registry-proxy-rc.json
kubectl create -f registry-proxy-svc.json
