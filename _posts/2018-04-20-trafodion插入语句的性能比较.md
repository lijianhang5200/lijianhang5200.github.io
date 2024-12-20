---
layout: post
category: 数据开发
title: "trafodion插入语句的性能比较"
tag: [ sql ]
excerpt: 记录trafodion各插入语句的性能信息。
---

## 摘要

记录trafodion各插入语句的性能信息

## 数据加载

- Insert 每秒百条
  insert into eboxdata_30m_new select * from eboxdata_30m;
- Upsert 每秒万条
  upsert into eboxdata_30m_new select * from eboxdata_30m;
- Upsert Using Load 每秒万条
  upsert using load into eboxdata_30m_new select * from eboxdata_30m;
- Load 每秒数十万条
  load into eboxdata_30m_new select * from eboxdata_30m;

从性能上面来看，这四种加载方式是依次递增的，即Load > Upsert Using Load > Upsert > Insert。
