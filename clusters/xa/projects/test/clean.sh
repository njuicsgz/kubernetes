#!/bin/bash

kubectl config set current-context my-context
kubectl config set-context my-context --namespace=test-allen

kubectl delete service,rc --all
