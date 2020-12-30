#!/bin/bash

kubectl apply -f secrets.yaml --namespace ci
kubectl create secret generic secret-configs --namespace ci \
  --from-file=devops-catalyst-systems.conf \
  --from-file=devops-catalyst-staging.conf \
  --from-file=devops-catalyst-qa.conf
