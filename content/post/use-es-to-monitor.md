---
title: "使用ES作为监控系统后端存储"
date: 2018-01-29T14:14:46+08:00
draft: false
---


## 优势

- 分布式系统查询效率高
- 搭配grafana可以很高效的做展示

## grafana配置ES数据源 

在datasource中添加es后端存储，配置对应的ES及对应的认证信息 索引信息


## 配置template

```
# 例如以nginx host为变量
{"find":"terms","field":"http_host.raw"}
```

## 选择 query
http_host:$servername

![](/img/es-monitor-query.png)