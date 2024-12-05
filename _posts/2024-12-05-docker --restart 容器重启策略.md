---
layout: post
category: 运维
title: "docker --restart 容器重启策略"
tag: [ docker ]
excerpt: docker --restart 容器重启策略。
---

## 介绍

用docker run命令的时候，用--restart 设置容器重启策略

| Flag | Description |
| --- | --- |
| no | 不自动重启容器。(默认) |
| on-failure\[:max-retries] | 如果容器因为错误退出了(退出码非0)，就会自动重启;如果守护程序重新启动，它不会重新启动容器。max-retries可选参数，最大重启尝试次数 |
| always | 只要容器停止，就重新启动容器。但是如果它是手动停止的，则仅在Docker守护程序重新启动或容器本身手动重新启动时才重新启动。 |
| unless-stopped | 和always类似，但如果是手动停止的，即使Docker守护程序重新启动，它也不会被自动启动 |

## 命令

```shell
# 以下命令启动Redis容器并将其配置为始终重新启动，除非该容器被显式停止。
docker run -d --restart unless-stopped redis

# 下面的命令为正在运行中的容器更改重启策略
docker update --restart always redis

# 下面的命令批量更改重启策略
docker update --restart always $(docker ps -q)
```
