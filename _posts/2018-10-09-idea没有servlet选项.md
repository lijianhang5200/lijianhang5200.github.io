---
layout: post
category: 开发
title: "idea没有servlet选项"
tag: [IDE]
excerpt: 在pom文件中加入下面的节点。
---

## 摘要

在pom文件中加入下面的节点：

```xml
<!--创建Servlet-->
<dependency>
  <groupId>jstl</groupId>
  <artifactId>jstl</artifactId>
  <version>1.2</version>
</dependency>
```

后就会出现servlet选项。
