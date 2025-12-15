#!/usr/bin/env bash
# Скрипт фильтрации подозрительных событий из audit.log

LOG=${1:-audit.log}

echo "=== Доступ к secrets ==="
jq 'select(.objectRef.resource=="secrets" and (.verb=="get" or .verb=="list" or .verb=="watch"))' "$LOG"

echo "=== Exec в pod ==="
jq 'select(.verb=="create" and .objectRef.subresource=="exec")' "$LOG"

echo "=== Привилегированные pod ==="
jq 'select(.objectRef.resource=="pods" and .requestObject.spec.containers[].securityContext.privileged==true)' "$LOG"

echo "=== Изменения audit policy ==="
grep -i 'audit-policy' "$LOG"
