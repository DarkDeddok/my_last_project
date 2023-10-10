#!/bin/bash
APP_NAME="stress-testing"

kubectl port-forward --namespace default svc/${APP_NAME}-database-mariadb 3306 &
kubectl port-forward --namespace default svc/${APP_NAME}-vault 8200 &
kubectl port-forward --namespace default svc/${APP_NAME}-esb 9080 &
kubectl port-forward --namespace default svc/${APP_NAME}-redis-master 6379 &

