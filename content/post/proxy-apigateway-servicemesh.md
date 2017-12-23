---
title: "代理、api网关与servicemesh"
date: 2017-12-20T11:27:13+08:00
draft: false
thumbnailImage: https://www.financeplus.com/wp-content/uploads/2013/06/cloud-it-csp7010092-620.jpg
thumbnailImagePosition: left
categories:
- servicemesh
tags:
- servicemesh

---
# 代理

#### 四层

- lvs
- haproxy
- F5

四层代理基于ip+port的负载均衡，功能:

- 全流量转发（mysql、redis等）

优势：

- 性能好，资源消耗低
- 应用广泛
- 配置项较少（也是劣势）

劣势：
- 可配置化程度低

#### 七层

- nginx
- haproxy
- Træfik

七层代理现在主要应用于HTTP协议，功能:

- 请求链接的负载均衡.
- 智能请求路由。
- 防御攻击（syn攻击）。

优势：

- 匹配规则灵活
- 对网络稳定性依赖较小
- 配置灵活

能用七层不用四层，七层可定制化程度高。

# api网关

- kong
- orange
- openresty
- zuul

功能：

- 服务发现
- 负载均衡
- 请求路由熔断
- 身份认证
- 熔断
- 流量管控
- 链路跟踪
- 监控

缺陷：

- 维护复杂的路由逻辑

# service mesh

服务网格分为控制面板和数据面板

### 控制面板

- linkerd
- envoy
- conduit-proxy

### 数据面板

- conduit
- istio
- contour (基于envoy)

# 相对于apigateway优势

- 集成服务发现
- 分布式系统，解耦，控制面板负责管理配置，数据面板根据配置进行相应的动作，上报状态到数据面板进行展示。
- sidecar模式,精确获取应用的详细信息，不受其他服务影响.
- 集中化配置，统一管理，相当于代理层的配置中心。

# 最终的目标：

## 应用部署层all in k8s,应用逻辑层all in servicemesh.
