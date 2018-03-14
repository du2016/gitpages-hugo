---
title: "使用plantuml"
date: 2017-12-19T20:05:54+08:00
draft: false
thumbnailImage: /img/plantuml.png
thumbnailImagePosition: left
categories:
- others
tags:
- plantuml
---
### PlantUML 是一个画图脚本语言，使用代码就可以画出我们想要的流程图

[官网](http://plantuml.com/)

[在线编辑](http://sujoyu.github.io/plantuml-previewer/)

[语法](https://yq.aliyun.com/articles/25404)

例：
```
@startuml

package "clientapp"{
    agent "User"
}

package "Services" {
User --> SLB : HTTP GET/POST
    package "zonea"{
        Nginx.A --> [ECS.A]
        [SLB] --> Nginx.A : internal RPC
    }
    package "zoneb"{
        Nginx.B --> [ECS.B] 
        [SLB] --> Nginx.B : internal RPC
    }
}
Nginx.A --> [ECS.B]
Nginx.B --> [ECS.A]
    database "kv"{
        JEDIS - [Redis]
        [ECS.A] --> JEDIS : get/put
        [ECS.B] --> JEDIS : get/put
    }
    database "RDS" {
      JDBC - [MySQL]
      [ECS.A] --> JDBC : CRUD
      [ECS.B] --> JDBC : CRUD
    }
@enduml
```


欢迎加入QQ群：k8s开发与实践（482956822）一起交流k8s技术