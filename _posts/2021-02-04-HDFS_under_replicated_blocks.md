---
layout: post
category: 数据运维
title:  "HDFS_under_replicated_blocks"
tag: [hadoop]
excerpt: under_replicated_blocks。
---

## 摘要

Under replicated blocks:指的是副本数少于指定副本数的block数量

Blocks with corrupt replicas: 指的是存在损坏副本的block的数据

Missing blocks:丢失block数量

```shell
for hdfsfile in `sudo -u hdfs hdfs fsck / | grep 'Under replicated' | awk -F':' '{print $1}'`; do echo "Fixing $hdfsfile :" ;  sudo hdfs hadoop fs -setrep 3 $hdfsfile; done
```
