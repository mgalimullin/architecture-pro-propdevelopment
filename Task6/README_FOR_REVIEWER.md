## Прдварительные выводы

Невозможно поянять ожидаемы логи отсутвуют из-за ошибок в описании задания или чего-то иного. Предоставленый в задаче audit-policy.yaml нерабочий. В курсе нет объяснения правильного запуска minikube и правильного способа извлечения логов аудита.

Невозможно понять чать команд запуска simulate-incident.sh завершаются ошибками из-за того что они так должны завершаться, или из-за того что в скрипте допущены ошибки.

Для меня почнит невозможно выполнить задание в описаном виде, т.к. нет понимания что является ожидаемым/неожидаемым/вредноносным поведением, и отсутвуют обущающие примеры что может быть таким поведением

Ниже результаты работы по таске

## Запуск

### 1

Исправил предложенный в дз audit-policy.yaml на
```yaml
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
- level: RequestResponse
  verbs: ["create", "delete", "update", "patch", "get", "list"]
  resources:
  - group: ""
    resources: ["pods", "secrets", "configmaps", "serviceaccounts", "roles", "rolebindings"]
- level: Metadata
  resources:
  - group: ""
    resources: ["*"]
```
с audit-policy.yaml из дз minikube не стартует

### 2
запуск minikube
```bash
╰─➤  minikube start --driver=docker --extra-config=apiserver.audit-policy-file=/etc/ssl/certs/audit-policy.yaml --extra-config=apiserver.audit-log-path=-                                                                                                                                                                                                                                                                                                                             130 ↵
😄  minikube v1.37.0 на Darwin 15.6.1 (arm64)
✨  Используется драйвер docker на основе конфига пользователя
📌  Using Docker Desktop driver with root privileges
👍  Starting "minikube" primary control-plane node in "minikube" cluster
🚜  Pulling base image v0.0.48 ...
🔥  Creating docker container (CPUs=2, Memory=7788MB) ...
❗  Failing to connect to https://registry.k8s.io/ from inside the minikube container
💡  To pull new external images, you may need to configure a proxy: https://minikube.sigs.k8s.io/docs/reference/networking/proxy/
🐳  Подготавливается Kubernetes v1.34.0 на Docker 28.4.0 ...
    ▪ apiserver.audit-policy-file=/etc/ssl/certs/audit-policy.yaml
    ▪ apiserver.audit-log-path=-
🔗  Configuring bridge CNI (Container Networking Interface) ...
🔎  Компоненты Kubernetes проверяются ...
    ▪ Используется образ gcr.io/k8s-minikube/storage-provisioner:v5
🌟  Включенные дополнения: default-storageclass, storage-provisioner
🏄  Готово! kubectl настроен для использования кластера "minikube" и "default" пространства имён по умолчанию
```

### 3
запуск simulate-incident.sh предложенныого в дз
```bash
╰─➤  ./simulate-incident.sh
namespace/secure-ops created
Context "minikube" modified.
serviceaccount/monitoring created
pod/attacker-pod created
no
Error from server (Forbidden): secrets is forbidden: User "system:serviceaccount:secure-ops:monitoring" cannot list resource "secrets" in API group "" in the namespace "kube-system"
pod/privileged-pod created
OCI runtime exec failed: exec failed: unable to start container process: exec: "cat": executable file not found in $PATH: unknown
command terminated with exit code 127
error: the path "/etc/kubernetes/audit-policy.yaml" does not exist
rolebinding.rbac.authorization.k8s.io/escalate-binding created
```

### 4

получаем audit.log командой
```bash
kubectl logs kube-apiserver-minikube -n kube-system | grep audit.k8s.io/v1
```

## выводы по запуску
### 1
kubectl auth can-i get secrets --as=system:serviceaccount:secure-ops:monitoring

ServiceAccount monitoring не имеет RBAC-прав

запрос разрешения был выполнен

API-server его залогировал (audit level: Metadata или RequestResponse)

### 2

```bash
kubectl get secret -n kube-system $(kubectl get secrets -n kube-system | grep default-token | head -n1 | awk '{print $1}') --as=system:serviceaccount:secure-ops:monitoring
```

вывод: 
```bash
rror from server (Forbidden): secrets is forbidden: User "system:serviceaccount:secure-ops:monitoring" cannot list resource "secrets" in API group "" in the namespace "kube-system"
```

```bash
kubectl get secrets -n kube-system'
NAME                     TYPE                            DATA   AGE
bootstrap-token-gzchn7   bootstrap.kubernetes.io/token   6      11m
```

не существует default-token с который пытаются грепнуть, соответвенно и вызов завершается ошибкой

### 3
privileged-pod создаётся

в логах не отображается событий типа
```
verb: create, resource: pods
```

### 4
```bash
kubectl exec -n kube-system $(kubectl get pods -n kube-system | grep coredns | awk '{print $1}' | head -n1) -- cat /etc/resolv.conf

exec: "cat": executable file not found in $PATH
```

coredns использует distroless / minimal image, в котором нет cat.

### 5
```bash
kubectl delete -f /etc/kubernetes/audit-policy.yaml --as=admin

error: the path "/etc/kubernetes/audit-policy.yaml" does not exist
```

### 6
RoleBinding срабатывает.

никаких событий типа `verb: "create"` в логе нет, как 



