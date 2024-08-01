---
layout: post
category: 开发
title:  "基于jersey的REST风格服务搭建"
tag: [ java ]
excerpt: 基于jersey的REST风格服务搭建。
---

## 基于JavaSE形式的REST服务

### maven配置

使用 **archetypeGroupId** 为 **org.glassfish.jersey.archetypes** , **archetypeArtifactId 为 **jersey-quickstart-grizzly2** 的原型，创建REST服务项目

### 构建和启动服务：

```shell
mvn package
mvn exec:java
```

### 访问

http://localhost:8080/myapp/application.wadl

得到

```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<application xmlns="http://wadl.dev.java.net/2009/02">
  <doc xmlns:jersey="http://jersey.java.net/" jersey:generatedBy="Jersey: 2.9.1 2014-06-01 23:30:50"/>
  <doc xmlns:jersey="http://jersey.java.net/" jersey:hint="This is simplified WADL with user and core resources only. To get full WADL with extended resources use the query parameter detail. Link: http://localhost:8080/myapp/application.wadl?detail=true"/>
  <grammars/>
  <resources base="http://localhost:8080/myapp/">
    <resource path="myresource">
      <method id="getIt" name="GET">
        <response>
          <representation mediaType="text/plain"/>
        </response>
      </method>
    </resource>
  </resources>
</application>
```

### 访问

http://localhost:8080/myapp/myresource

得到
```html
Got it!
```

## 基于Servlet容器服务

### maven配置

使用 **archetypeGroupId** 为 **org.glassfish.jersey.archetypes** , **archetypeArtifactId** 为 **jersey-quickstart-webapp** 的原型，创建REST服务项目

### 配置tomcat

### 访问服务

http://localhost:8080/project_name
```xml
<properties>
  <jersey.version>2.9.1</jersey.version>
  <mysql.version>5.1.46</mysql.version>
  <jersey.version>2.27</jersey.version>
  <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
</properties>
<dependencies>
<dependency>
  <groupId>org.glassfish.jersey.containers</groupId>
  <artifactId>jersey-container-servlet-core</artifactId>
  <version>${jersey.version}</version>
  <!-- use the following artifactId if you don't need servlet 2.x compatibility -->
  <!-- artifactId>jersey-container-servlet</artifactId -->
</dependency>
<dependency>
  <groupId>org.glassfish.jersey.containers</groupId>
  <artifactId>jersey-container-grizzly2-http</artifactId>
  <version>${jersey.version}</version>
</dependency>
<dependency>
  <groupId>org.glassfish.jersey.inject</groupId>
  <artifactId>jersey-hk2</artifactId>
  <version>${jersey.version}</version>
</dependency>
<dependency>
  <groupId>org.glassfish.jersey.inject</groupId>
  <artifactId>jersey-hk2</artifactId>
  <version>${jersey.version}</version>
</dependency>
<dependency>
  <groupId>org.glassfish.jersey.media</groupId>
  <artifactId>jersey-media-moxy</artifactId>
  <version>${jersey.version}</version>
</dependency>
<dependency>
  <groupId>org.glassfish.jersey.media</groupId>
  <artifactId>jersey-media-json-jackson</artifactId>
  <version>${jersey.version}</version>
</dependency>
<!-- Java 8/9 -->
<dependency>
  <groupId>com.zaxxer</groupId>
  <artifactId>HikariCP</artifactId>
  <version>3.1.0</version>
</dependency>
<dependency>
  <groupId>mysql</groupId>
  <artifactId>mysql-connector-java</artifactId>
  <version>${mysql.version}</version>
</dependency>
<dependency>
  <groupId>com.alibaba</groupId>
  <artifactId>fastjson</artifactId>
  <version>1.2.47</version>
</dependency>
</dependencies>
```
