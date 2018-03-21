---
title: "How to Use Jenkinx"
date: 2018-03-21T21:22:30+08:00
draft: true
---

# jenkins X

Jenkins X 是一个高度集成化的CI/CD平台，基于Jenkins和Kubernetes实现，
旨在解决微服务体系架构下的云原生应用的持续交付的问题，简化整个云原生应用的开发、
运行和部署过程a


# 安装jx

## mac

通过brew安装
```bash
brew tap jenkins-x/jx
brew install jx 
```

二进制安装
```
curl -L https://github.com/jenkins-x/jx/releases/download/v1.1.10/jx-darwin-amd64.tar.gz | tar xzv 
sudo mv jx /usr/local/bin
```

### linux

```
curl -L https://github.com/jenkins-x/jx/releases/download/v1.1.10/jx-linux-amd64.tar.gz | tar xzv 
sudo mv jx /usr/local/bin
```

## 其它平台

[下载二进制](https://github.com/jenkins-x/jx/releases)的jx，并把它添加到您的$PATH

## 使用帮助

```
jx help create
```

# 创建安装了jenkins的k8s集群

## gke

```
jx create cluster gke
```

## aws

```
jx create cluster aws
```

## aks

```bash
jx create cluster minikube
```