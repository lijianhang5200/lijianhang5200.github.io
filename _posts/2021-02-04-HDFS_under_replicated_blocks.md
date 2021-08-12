---
layout: post
title:  "HDFS_under_replicated_blocks"
tags: [hadoop]
---
### 摘要

<!--excerpt-->

Under replicated blocks:指的bai是副本数少于指定副du本数的block数量
Blocks with corrupt replicas: 指的是存在损zhi坏副dao本的block的数zhuan据
Missing blocks:丢失shublock数量

```shell
for hdfsfile in `sudo -u hdfs hdfs fsck / | grep 'Under replicated' | awk -F':' '{print $1}'`; do echo "Fixing $hdfsfile :" ;  sudo hdfs hadoop fs -setrep 3 $hdfsfile; done
```

