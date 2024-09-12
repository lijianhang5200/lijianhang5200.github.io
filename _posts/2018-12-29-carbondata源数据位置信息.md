---
layout: post
category: 数据运维
title:  "carbondata源数据位置信息"
tag: [ hadoop ]
excerpt: 记录找到的carbondata数据在mysql的hive表中的情况。
---

## 摘要

记录找到的carbondata数据在mysql的hive表中的情况。

## mysql数据库软件hive表

- **cds** 
- **columns_v2** 
- **dbs**

  数据库相关信息，包括 数据库id,数据库描述,数据库位置,数据库名称，数据库拥有者，拥有者类型

- **global_privs**

  全局权限表,包括 角色id, 创建时间， 权限类型， 授权名称， 授权类型， 用户权限等

- **next_lock_id** 
- **next_txn_id** 
- **roles**

  角色信息，包括 角色id，创建时间，拥有者名称， 角色名称
- **sds**

  包括 表文件输入格式，是否压缩，存储子目录，表位置，通数量，表文件输出格式，序列id(待定)

- **sequence_table**

  序列名称，下一个值

- **serde_params**

  表详情信息，包括 序列id(待定)， 表名， 保存路径， 是否扩展等信息

- **serdes** 
- **table_params**

  表详情信息,包括 字段信息， 事务最后执行时间，
 
- **tbls**

  表详情信息,包括 创建时间等

## hive数据库软件hdfs目录


