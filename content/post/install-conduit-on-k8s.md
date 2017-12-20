---
title: "conduit 初探"
date: 2017-12-18T19:10:02+08:00
draft: false
thumbnailImage: /img/conduit.png
thumbnailImagePosition: left
categories:
- servicemesh
tags:
- Conduit
- kubernetes
---

# Conduit 介绍

Conduit是buoyant公司出品的，面向k8s的servicemesh产品，该公司另外一个产品为linkerd，现在业界唯一的生产级servicemesh产品。目标是在无需代码的改动就可以实现对应用程序的可见和控制。

# 环境

- kubernetes 1.8+

在没有k8s环境的情况下，推荐使用minikube来快速生成。

# 安装cli

```
curl https://run.conduit.io/install | sh
```

# 安装conduit控制面板

```
conduit install | kubectl apply -f -
conduit dashboard
```

官方的程序目前没有自动创建serviceaccount，需要手动创建serviceaccount，分配clusterrole，应用到deploy

```
kubectl create serviceaccount conduit --namespace=conduit

cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: condit:cluster-admin
  namespace: kube-system
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: conduit
  namespace: conduit
EOF

分别修改controller和prometheus应用添加serviceAccount: conduit
kubectl get deploy --namespace=conduit controller
kubectl get deploy --namespace=conduit prometheus
```

# 安装官方的演示程序

```
curl https://raw.githubusercontent.com/runconduit/conduit-examples/master/emojivoto/emojivoto.yml | conduit inject - --skip-inbound-ports=80 | kubectl apply -f -
```

官方的演示程序web-svc使用的loadbalance,修改为`type: NodePort`
### 给demo程序加压

```
$INGRESS=`kubectl get svc web-svc -n emojivoto -o jsonpath="{.spec.clusterIP}"`:80
while true; do curl $INGRESS; done
```

![Conduit Dashboard](/img/conduit-dashboard.png)
在访问conduit dashboard查看服务的状态,除了dashboard外还可以通过 `conduit stat` 和 `conduit tap`来观测服务状态

# 添加自己的服务到conduit

```
conduit inject deployment.yml | kubectl apply -f -
```

# 绕过代理
conduit仅支持http/2流量，绕过代理：
```
conduit inject deployment.yml --skip-inbound-ports=80,7777 | kubectl apply -f -
```