#!/bin/bash

kubectl config set current-context my-context
kubectl config set-context my-context --namespace=facebook-pmd

kubectl delete service,rc --all
sleep 1
kubectl delete pod --all
