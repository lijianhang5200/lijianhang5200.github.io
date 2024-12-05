---
layout: post
category: 运维
title: "Docker报port is already allocated错误"
tag: [ docker ]
excerpt: Docker报port is already allocated错误。
---

## 问题：

在创建容器的时候报：port is already allocated的错误。

port is already allocated.

### 原因分析：

之前创建过对应的容器，删除容器后，相关的配置还在，导致再创建容器时提示端口已经被分配。


## 解决方案

```shell
# 查看在运行的进程
docker ps

# 删除所有容器
docker rm $(docker ps -qa)

# 停止容器服务
systemctl stop docker

# 删除local-kv.db文件
rm -rf /data/docker/network/files/local-kv.db

# 重新启动docker服务
systemctl start docker

# 重新创建容器
```

#### 参考地址

[https://www.modb.pro/db/1767721846804385792](https://www.modb.pro/db/1767721846804385792)
