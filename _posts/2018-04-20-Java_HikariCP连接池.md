---
layout: post
category: 后端
title: "HiKariCP数据库连接池的使用"
tag: [ java ]
excerpt: HiKariCP是数据库连接池的一个后起之秀，号称性能最好，可以完美地PK掉其他连接池。
---

### 简介

HiKariCP是数据库连接池的一个后起之秀，号称性能最好，可以完美地PK掉其他连接池。

### 参考教程

[https://github.com/brettwooldridge/HikariCP](https://github.com/brettwooldridge/HikariCP)

### spring 配置 

```xml
<!-- HikariCP 高性能数据库连接池 -->
<bean id="dataSourceHikari" class="com.zaxxer.hikari.HikariDataSource">
  <property name="driverClassName" value="com.mysql.jdbc.Driver"/>
  <property name="jdbcUrl" value="jdbc:mysql://localhost:3306/black1?useUnicode=true&amp;characterEncoding=UTF-8"/>
  <property name="username" value="root"/>
  <property name="password" value=""/>
  <!-- Default settings -->
  <!-- 控制自动提交行为 default：true -->
  <property name="autoCommit" value="true"/>
  <!--连接池获取的连接是否只读 default:false-->
  <property name="readOnly" value="false"/>
  <!--控制连接的事务隔离等级 default:none-->
  <property name="transactionIsolation" value="none"/>
  <!--设置catalog以便于支持查看catalogs ， 若不指定的话将直接使用 JDBC driver使用的 default:none-->
  <property name="catalog" value="none"/>
  <!--最大连接超时时间 default：30秒-->
  <property name="connectionTimeout" value="30000"/>
  <!--最大空闲超时时间 default：10分钟   -->
  <property name="idleTimeout" value="600000"/>
  <!--连接池中一个连接的最大生命周期 default：30分钟-->
  <property name="maxLifetime" value="1800000 "/>
  <!--  ...还有一些其他配置属性 有兴趣可以看看 O(∩_∩)O哈哈~ -->
</bean>
```
