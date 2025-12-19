#!/bin/bash
echo "[+] Testing insecure manifests (should FAIL)"
kubectl apply -f insecure-manifests/ || true

echo "[+] Testing secure manifests (should PASS)"
kubectl apply -f secure-manifests/
