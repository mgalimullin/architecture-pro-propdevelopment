# Отчёт по результатам анализа Kubernetes Audit Log

## Подозрительные события

1. Доступ к секретам:
   - Кто: "username": "kubernetes-admin"
   - Где: /api/v1/namespaces/kube-system/secrets/bootstrap-token-gzchn7?timeout=10s
   - Почему подозрительно: запросы несуществующих секртов "secrets \"bootstrap-token-gzchn7\" not found"

2. Привилегированные поды:
   - Кто:  "username": "system:serviceaccount:kube-system:daemon-set-controller", "username": "minikube-user"
   - Комментарий: "verb": "create" неожиданное создание привелегорованных подов

3. Использование kubectl exec в чужом поде:
   - нет результата

4. Создание RoleBinding с правами cluster-admin:
   - Кто: "username": "kubernetes-admin"
   - К чему привело: создание новой RoleBinding

5. Удаление audit-policy.yaml:
   - нет

## Вывод
нет выводов
