#!/bin/bash

kubectl apply -f admin_role.yaml
kubectl apply -f root_role.yaml
kubectl apply -f viewer_role.yaml
