---
layout: post
category: 数据运维
title: "CarbonData编译CDH版本"
tag: [ hadoop ]
excerpt: CarbonData编译CDH版本需要配置settings.xml文件、pom.xml文件。
---

## 介绍

CarbonData编译CDH版本需要配置settings.xml文件、pom.xml文件。

## 在settings.xml增加配置

```xml
<!-- CDH 仓库 -->
<mirror>
  <id>Cloudera</id>
  <mirrorOf>*</mirrorOf>
  <name>Cloudera</name>
  <url>https://repository.cloudera.com/artifactory/cloudera-repos/</url>
</mirror>
```

## 在pom.xml修改镜像配置

```xml
<repositories>
  <repository>
    <id>Cloudera</id>
    <!-- This should be at top, it makes maven try the central repo first and then others and hence faster dep resolution -->
    <name>Cloudera</name>
    <url>https://repository.cloudera.com/artifactory/cloudera-repos/</url>
    <releases>
      <enabled>true</enabled>
    </releases>
  </repository>
</repositories>
```

## 修改 pom.xml 中依赖

```xml
<dependency>
  <groupId>org.apache.spark</groupId>
  <artifactId>spark-hive-thriftserver_${scala.binary.version}</artifactId>
  <version>2.1.0</version>
  <scope>${spark.deps.scope}</scope>
</dependency>
```

## 执行编译

```shell
mvn -DskipTests -Dspark.deps.scope=provided -Dhadoop.deps.scope=provided -Dscala.deps.scope=provided -Pspark-2.1 -Dspark.version=2.1.0.cloudera3 -Phadoop-2.6.0-cdh5.16.1 -Dhadoop.version=2.6.0-cdh5.16.1 -Phive -Phive-thriftserver clean package
```

#### 参考网址

[https://blog.csdn.net/haohaizijhz/article/details/72841489](https://blog.csdn.net/haohaizijhz/article/details/72841489) 其中包括maven多镜像配置
