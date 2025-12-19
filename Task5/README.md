## Назначьте метки для сервисов.

Метки выполняют функцию ролей для сервиса:

1. front-end
2. back-end-api
3. admin-front-end
4. admin-back-end-api

```bash
kubectl run front-end-app --image=nginx --labels role=front-end --expose --port 80
kubectl run back-end-api-app --image=nginx --labels role=back-end-api --expose --port 80
kubectl run admin-front-end-app --image=nginx --labels role=admin-front-end --expose --port 80
kubectl run admin-back-end-api-app --image=nginx --labels role=admin-back-end-api --expose --port 80
```

### Создайте сетевые политики.

front-end <-> back-end-api
admin-back-end-api <-> admin-back-end-api

```bash
kubectl apply -f non-admin-api-allow.yaml
```


## --
Когда настроите и примените сетевые политики, проверьте, что трафик есть между сервисами, для которых он разрешён, но его нет между сервисами, для которых он запрещён. Для этого используйте команду:

```bash
kubectl exec front-end-app -- curl  http://front-end-app 
kubectl exec front-end-app -- curl  http://back-end-api-app
kubectl exec front-end-app -- curl  http:/admin-front-end-app
kubectl exec front-end-app -- curl  http://admin-back-end-api-app

```

## minikube проблему

необходимо включить cni чтоб NetwokPolicy работали. по умолчанию оно не работает в minikube
```bash
minikube delete
minikube start --driver=docker --network-plugin=cni --cni=calico
```

проверка
```bash
kubectl get pods -n kube-system
```

должны быть
```
calico-node-xxxxx
calico-kube-controllers-xxxxx
```

Если их нет — NetworkPolicy не будет работать никогда.

