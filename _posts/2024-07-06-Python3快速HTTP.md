---
layout: post
category: 运维
title: Python3快速搭建一个HTTP服务
tag: [python]
excerpt: 快速搭建一个 HTTP 服务，用于测试网络联通情况。
---

## 使用默认 8000 端口

```shell
# 8000
python -m http.server -b 192.168.188.125
python -m http.server --bind :: # ipv6
```

## 指定 8008 端口

```shell
# 8008
python -m http.server 8008
```
