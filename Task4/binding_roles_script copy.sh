#!/bin/bash

kubectl apply -f admin_binding.yaml
kubectl apply -f root_binding.yaml
kubectl apply -f viewer_binding.yaml
