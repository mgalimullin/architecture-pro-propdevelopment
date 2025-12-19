#!/bin/bash
echo "[+] Checking running pods"
kubectl get pods -n audit-zone
