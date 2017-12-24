---
title: "[译]Kube Router Documentation"
date: 2017-12-21T14:29:36+08:00
draft: false
thumbnailImage: https://raw.githubusercontent.com/cloudnativelabs/kube-router/master/Documentation/img/kube-router-arch.png
thumbnailImagePosition: left
categories:
- kubernetes
tags:
- Kube-router
---

## 体系结构


Kube-router是围绕观察者和控制器的概念而建立的。 观察者使用Kubernetes监视API来获取与创建，更新和删除Kubernetes对象有关的事件的通知。 每个观察者获取与特定API对象相关的通知。 在从API服务器接收事件时，观察者广播事件。 控制器注册以获取观察者的事件更新，并处理事件。


Kube-router由3个核心控制器和多个观察者组成，如下图所示。

![Arch](https://raw.githubusercontent.com/cloudnativelabs/kube-router/master/Documentation/img/kube-router-arch.png)

每个 [controller](https://github.com/cloudnativelabs/kube-router/tree/master/app/controllers) 遵循以下结构

```
func Run() {
    for {
        Sync() // control loop that runs for ever and perfom sync at periodic interval
    }
}

func OnUpdate() {
    Sync() // on receiving update of a watched API object (namespace, node, pod, network policy etc)
}

Sync() {
    //re-concile any state changes
}

Cleanup() {
    // cleanup any changes (to iptables, ipvs, network etc) done to the system
}
```

## 查看Kube-router实战

#### 网络服务控制器


网络服务控制器负责从Kubernetes API服务器读取服务和端点信息，并相应地在每个群集节点上配置IPVS。

请阅读博客基于iptables与Kube-proxy的设计细节和利弊对比
https://cloudnativelabs.github.io/post/2017-05-10-kube-network-service-proxy/

基于Kubernetes网络服务代理的Kube-route IPVS演示

[![asciicast](https://asciinema.org/a/120312.png)](https://asciinema.org/a/120312)

特征:

- 轮询负载均衡
- 基于客户端IP的会话保持
- 如果服务控制器与网络路由控制器（带有--run-router标志的kube-router）一起使用，源IP将被保留。
- 用--masquerade-all参数明确标记伪装(SNAT)

#### 网络策略控制器

网络策略控制器负责从Kubernetes API服务器读取命名空间，网络策略和pod信息，并相应地配置iptables以向pod提供入口过滤.

Kube-router支持networking.k8s.io/NetworkPolicy接口或网络策略V1/GA
[semantics](https://github.com/kubernetes/kubernetes/pull/39164#issue-197243974)以及网络策略的beta语义

请阅读博客网络策略控制器的设计细节
https://cloudnativelabs.github.io/post/2017-05-1-kube-network-policies/

Kube-router的iptables基于网络策略的实现演示

[![asciicast](https://asciinema.org/a/120735.png)](https://asciinema.org/a/120735)

#### 网络路由控制器

网络路由控制器负责读取由控制器管理器分配给节点的pod CIDR，并将路由通告给集群中其余节点（BGP peers）。对于基于pod-to-pod网络，使用BGP对于用户来说是透明的.

[![asciicast](https://asciinema.org/a/120885.png)](https://asciinema.org/a/120885)

但是，BGP可以用于其他用例，如通告集群ip，可路由pod ip等。只有在这种情况下，才需要了解BGP和配置。请参阅下面的演示kube-router如何向外部BGP路由器发布集群IP和pod cidrs
[![asciicast](https://asciinema.org/a/121635.png)](https://asciinema.org/a/121635)

## 用户指南

### 尝试使用集群安装程序安装Kube-router

在Kubernetes上部署Kube-router的最好的入门方法是使用集群安装程序.

#### kops
请查看[steps](https://github.com/cloudnativelabs/kube-router/blob/master/Documentation/kops.md) 使用[Kops](https://github.com/kubernetes/kops)部署Kubernetes集群与Kube-router。

#### bootkube
请查看[steps](https://github.com/cloudnativelabs/kube-router/tree/master/contrib/bootkube) 使用 [bootkube](https://github.com/kubernetes-incubator/bootkube)部署Kubernetes集群与Kube-router。

#### kubeadm
请查看[steps](https://github.com/cloudnativelabs/kube-router/blob/master/Documentation/kubeadm.md)使用[Kubeadm](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/)部署Kubernetes集群与Kube-router。

### deployment

根据要使用的kube-router的功能，可以使用多个部署选项. 你可以使用这些参数 `--run-firewall`, `--run-router`, `--run-service-proxy` 有选择地只启用kube-router所需的功能。

您也可以选择运行kube-router作为在每个群集节点上运行的agent。 另外可以通过daemonset在每个节点上运行kube-router作为pod。

### 命令行选项

```
Usage of ./kube-router:
      --advertise-cluster-ip                将该服务的集群IP添加到RIB，以便通告给BGP peers.
      --advertise-external-ip               将服务的外部IP添加到RIB，以便将其通告给BGP peers.
      --cleanup-config                      清理iptables规则，ipvs，ipset配置并退出.
      --cluster-asn uint                    集群节点运行iBGP的ASN编号.
      --cluster-cidr string                 群集中的CIDR范围。它被用来识别pods的范围.
      --config-sync-period duration         apiserver配置同步之间的延迟（例如“5s”，“1m”）。必须大于0.（默认1m0s）
      --enable-overlay                      当enable-overlay设置为true时，IP-in-IP隧道将用于跨不同子网中节点的pod-pod联网。如果设置为false，则不使用隧道，并且路由基础架构预计为不同子网中的节点之间的pod-pod联网路由流量（默认值为true）
      --enable-pod-egress                   从Pod到群集外的SNAT流量。 （默认为true）
      --hairpin-mode                        为每个服务端点添加iptable规则以支持流量管控.
  -h, --help                                打印使用信息.
      --hostname-override string            覆盖节点的NodeName。如果kube-router无法自动确定您的NodeName，请设置此项.
      --iptables-sync-period duration       iptables规则同步之间的延迟（例如'5s'，'1m'）。必须大于0.（默认1m0s）
      --ipvs-sync-period duration           ipvs config同步之间的延迟（例如'5s'，'1m'，'2h22m'）。必须大于0.（默认1m0s）
      --kubeconfig string                   具有授权信息的kubeconfig文件的路径（主位置由主标志设置）。
      --masquerade-all                      SNAT所有流量到群集IP /节点端口。
      --master string                       Kubernetes API服务器的地址（覆盖kubeconfig中的任何值）。
      --nodeport-bindon-all-ip              对于NodePort类型的服务，创建监听节点的所有IP的IPVS服务.
      --nodes-full-mesh                     集群中的每个节点都将建立与其他节点的BGP对等关系。 （默认为true）
      --peer-router-asns uintSlice          集群节点将向其通告集群ip和节点的pid cidr的BGP peers的ASN编号。 （默认[]）
      --peer-router-ips ipSlice             所有节点将对等的外部路由器的IP地址，并通告集群ip和pod cidr。 （默认[]）
      --peer-router-passwords stringSlice   用“--peer-router-ips”定义的BGP peers进行认证的密码。
      --routes-sync-period duration         路线更新与广播之间的延迟（例如“5s”，“1m”，“2h22m”）。必须大于0.（默认1m0s）
      --run-firewall                        启用网络策略 - 设置iptables为pod提供入口防火墙。 （默认为true）
      --run-router                          启用Pod网络 - 通过iBGP发布并学习到Pod的路由。 （默认为true）
      --run-service-proxy                   启用服务代理 - 为Kubernetes服务设置IPVS。 （默认为true）```
```

### 依赖

- Kube-router需要访问kubernetes API服务器以获取有关Pod，服务，端点，网络策略等的信息。所需的最少信息是关于在何处访问kubernetes API服务器的详细信息. 这个信息可以通过`kube-router --master=http://192.168.1.99:8080/`或`kube-router --kubeconfig=<kubeconfig文件路径>`传递。

- 如果在节点上运行kube-router作为agent，则必须在每个节点上安装ipset软件包（当以守护进程集的形式运行时，容器映像将使用ipset预先打包）

- 如果您选择使用kube-router进行pod-to-pod网络连接，则需要将Kubernetes控制器管理器通过传递`--allocate-node-cidrs=true`标志并提供`cluster-cidr`来配置分配pod CIDR。 （例如通过传递--cluster-cidr = 10.1.0.0 / 16）

- 如果您选择以守护进程运行kube-router，那么kube-apiserver和kubelet必须以“--allow-privileged=true”选项运行

- 如果您选择使用kube-router作为pod-to-pod网络连接，则必须将Kubernetes集群配置为使用CNI网络插件。在每个节点上，CNI conf文件预计将以/etc/cni/net.d/10-kuberouter.conf的形式出现。应使用CNI插件和用于IPAM的“host-local”。示例conf文件，可以下载`wget -O /etc/cni/net.d/10-kuberouter.conf https://raw.githubusercontent.com/cloudnativelabs/kube-router/master/cni/10-kuberouter .conf`

### 作为daemonset运行

这是部署kube-router（**不要忘记确保需求**）的最快方法。只需运行：

```
kubectl apply -f https://raw.githubusercontent.com/cloudnativelabs/kube-router/master/daemonset/kube-router-all-service-daemonset.yaml
```

以上将自动在每个节点上运行kube-router作为pod。您可以根据需要更改daemonset中定义的参数以匹配您的需要。有些示例可以在`https://github.com/cloudnativelabs/kube-router/tree/master/daemonset`中找到，使用不同的参数来选择kube-router应运行的服务.

### 作为agent运行

您可以选择运行kube-router作为在每个节点上运行的代理。例如，如果您只想让kube-router为pod提供入口防火墙，那么您可以这样启动kube-router
```
kube-router --master=http://192.168.1.99:8080/ --run-firewall=true --run-service-proxy=false --run-router=false
```

### 清理配置

您可以通过运行在节点上的kube-router清除所有已完成的配置（对ipvs，iptables，ip routes）
```
 kube-router --cleanup-config
```

### 尝试使用kube-router作为kube-proxy的替代品

如果你有一个使用kube-proxy，并且想要尝试kube-router来做服务代理，你可以这样做
```
kube-proxy --cleanup-iptables
```
接下来
```
kube-router --master=http://192.168.1.99:8080/ --run-service-proxy=true --run-firewall=false --run-router=false
```
如果你想回到kube-proxy，那么通过运行清理由kube-router完成的配置
```
 kube-router --cleanup-config
```
并使用您的配置运行kube-proxy。

- [一般步骤](/README.md#getting-started)

### Hairpin Mode

从service后面的Pod到其自己的ClusterIP:PORT的通信
默认不支持。不过，可以通过对每个服务添加`kube-router.io/service.hairpin=`注释，或者通过集群中的所有服务启动。

另外, 对于每个节点上的所有veth接口，`hairpin_mode`sysctl选项必须设置为`1`. 这可以通过在您的CNI配置中添加`“hairpinMode”：true`选项来完成，如果所有集群节点已经在运行kubernetes。

如果发送源IP来自Service ClusterIP，Hairpin traffic将被发现的发送点看到。

#### Hairpin Mode示例

10-kuberouter.conf
```json
{
    "name":"mynet",
    "type":"bridge",
    "bridge":"kube-bridge",
    "isDefaultGateway":true,
    "hairpinMode":true,
    "ipam": {
        "type":"host-local"
     }
}
```

为服务“my-service”启用hairpin traffic：
```
kubectl annotate service my-service "kube-router.io/service.hairpin="
```

### 服务器直接返回

请阅读以下博客，了解如何结合使用DSR和“--advertise-external-ip”构建高度可扩展和可用的入口。
https://cloudnativelabs.github.io/post/2017-11-01-kube-high-available-ingress/

您可以为每个服务启用DSR（直接服务器返回）功能。当启用的服务端点将直接响应客户端通过签署服务代理。启用DSR时，Kube-router将使用LVS的隧道模式来实现此功能。

要启用DSR，您需要使用`kube-router.io/service.dsr = tunnel`注释来注释服务。例如，

```
kubectl annotate service my-service "kube-router.io/service.dsr=tunnel"
```

**在当前的实现中，当在服务上应用注释时，DSR将仅适用于外部IP。**

**此外，当使用DSR时，当前的实现不支持端口重新映射。所以你需要使用相同的端口和目标端口的服务**

你需要在kube-router守护进程清单中启用`hostIPC：true`和`hostPID：true`。并且必须将主路径`/var/run/docker.sock`设置为kube-router的一个volumemount。

上述更改需要kube-router输入pod namespace，并在pod中创建ipip隧道，并将外部IP分配给VIP。 

对于示例清单，请查看启用DSR要求的 [manifest]("../ daemonset / kubeadm-kuberouter-all-features-dsr.yaml")


### 负载均衡调度算法

Kube-router使用LVS作为服务代理。 LVS支持丰富的[调度算法](http://kb.linuxvirtualserver.org/wiki/IPVS#Job_Scheduling_Algorithms)。您可以为该服务添加注释以选择一个调度算法。当一个服务没有注释时，默认情况下选择“轮询”调度策略

```
For least connection scheduling use:
kubectl annotate service my-service "kube-router.io/service.scheduler=lc"

For round-robin scheduling use:
kubectl annotate service my-service "kube-router.io/service.scheduler=rr"

For source hashing scheduling use:
kubectl annotate service my-service "kube-router.io/service.scheduler=sh"

For destination hashing scheduling use:
kubectl annotate service my-service "kube-router.io/service.scheduler=dh"
```

## BGP 配置

[Configuring BGP Peers](bgp.md)