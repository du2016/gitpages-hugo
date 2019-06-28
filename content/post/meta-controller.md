---
title: "Meta Controller"
date: 2019-06-28T14:36:03+08:00
draft: false
categories:
- kubernetes
tags:
- k8s
---
# 简介
Metacontroller是GKE为k8s开发的一个附加组件，用简单的脚本便可以方便的管理自定义控制器。

# 概念

- CRD 自定义资源
- Metacontroller Metacontroller控制器本身
- DecoratorController Metacontroller中用于向现有资源添加新行为
- CompositeController Metacontroller中用于通过父对象管理子对象

# 安装

```bash
# 创建命名空间
kubectl create namespace metacontroller
# 创建serviceaccount和rolebiding
kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/metacontroller/master/manifests/metacontroller-rbac.yaml
# 创建metacontroller crd 和 metacontroller statefulset
kubectl apply -f https://raw.githubusercontent.com/GoogleCloudPlatform/metacontroller/master/manifests/metacontroller.yaml
```

# 创建一个控制器

## 目标

通过HelloWorld自定义资源来创建pod，打印hello


## 创建HelloWorld CRD

```bash
cat << EOF | kubectl apply -f -
apiVersion: apiextensions.k8s.io/v1beta1
kind: CustomResourceDefinition
metadata:
  name: helloworlds.example.com
spec:
  group: example.com
  version: v1
  names:
    kind: HelloWorld
    plural: helloworlds
    singular: helloworld
  scope: Namespaced
EOF
```

## 创建CompositeController

```
cat << EOF | kubectl apply -f -
apiVersion: metacontroller.k8s.io/v1alpha1
kind: CompositeController
metadata:
  name: hello-controller
spec:
# 生成标签，模拟内置job，防止夸资源共享pod
  generateSelector: true
# watch的父资源  
  parentResource:
    apiVersion: example.com/v1
    resource: helloworlds
# 生成的子资源
  childResources:
  - apiVersion: v1
    resource: pods
    updateStrategy:
      method: Recreate
# 钩子
  hooks:
    sync:
      webhook:
        url: http://hello-controller.hello/sync
EOF
```

## 实现自己的webhook

webhook流程

创建crd resource -->metacontroller收到变化通知--->发送crd和期望pod数量到webhook ---> 
webhook解析crd返回pod列表,及请求状态（pod数量）--->metacontroller判断状态正常--->创建pod

webhook示例：
```bash
from BaseHTTPServer import BaseHTTPRequestHandler, HTTPServer
import json

class Controller(BaseHTTPRequestHandler):
  def sync(self, parent, children):
    # Compute status based on observed state.
    desired_status = {
      "pods": len(children["Pod.v1"])
    }

    # Generate the desired child object(s).
    who = parent.get("spec", {}).get("who", "World")
    desired_pods = [
      {
        "apiVersion": "v1",
        "kind": "Pod",
        "metadata": {
          "name": parent["metadata"]["name"]
        },
        "spec": {
          "restartPolicy": "OnFailure",
          "containers": [
            {
              "name": "hello",
              "image": "busybox",
              "command": ["echo", "Hello, %s!" % who]
            }
          ]
        }
      }
    ]

    return {"status": desired_status, "children": desired_pods}

  def do_POST(self):
    # Serve the sync() function as a JSON webhook.
    observed = json.loads(self.rfile.read(int(self.headers.getheader("content-length"))))
    desired = self.sync(observed["parent"], observed["children"])

    self.send_response(200)
    self.send_header("Content-type", "application/json")
    self.end_headers()
    self.wfile.write(json.dumps(desired))

HTTPServer(("", 80), Controller).serve_forever()
```