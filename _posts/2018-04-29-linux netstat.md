---
layout: post
category: 运维
title:  "linux netstat命令的使用"
tag: [linux]
excerpt: netstat 命令用于显示各种网络相关信息，如网络连接，路由表，接口状态 (Interface Statistics)，masquerade 连接，多播成员 (Multicast Memberships) 等等。
---

## 简介

netstat 命令用于显示各种网络相关信息，如网络连接，路由表，接口状态 (Interface Statistics)，masquerade 连接，多播成员 (Multicast Memberships) 等等。

## 安装

```shell
yum install net-tools
```

## 常见参数

```shell
-a (all)显示所有选项，默认不显示LISTEN相关
-t (tcp)仅显示tcp相关选项
-u (udp)仅显示udp相关选项
-n 拒绝显示别名，能显示数字的全部转化成数字。
-l 仅列出有在 Listen (监听) 的服務状态

-p 显示建立相关链接的程序名
-r 显示路由信息，路由表
-e 显示扩展信息，例如uid等
-s 按各个协议进行统计
-c 每隔一个固定时间，执行该netstat命令。
```

提示：LISTEN和LISTENING的状态只有用-a或者-l才能看到

## 实用命令实例

### 列出所有端口 (包括监听和未监听的)

```shell
netstat -a # 列出所有端口
netstat -at # 列出所有 tcp 端口
netstat -au # 列出所有 udp 端口
```

### 列出所有处于监听状态的 Sockets

```shell
netstat -l # 只显示监听端口
netstat -lt # 只列出所有监听 tcp 端口
netstat -lu # 只列出所有监听 udp 端口
netstat -lx # 只列出所有监听 UNIX 端口
```

### 显示每个协议的统计信息

```shell
netstat -s # 显示所有端口的统计信息
netstat -st 或 -su # 显示 TCP 或 UDP 端口的统计信息 
```

### 在 netstat 输出中显示 PID 和进程名称

```shell
netstat -p
```

### 在 netstat 输出中不显示主机，端口和用户名 (host, port or user)

```shell
netstat -n # 当你不想让主机，端口和用户名显示。将会使用数字代替那些名称。
```

### 持续输出 netstat 信息

```shell
netstat -c # netstat 将每隔一秒输出网络信息
```

### 显示系统不支持的地址族 (Address Families)

```shell
netstat --verbose
```

### 显示核心路由信息

```shell
netstat -r
```

### 找出程序运行的端口

```shell
netstat -ap | grep ssh
netstat -an | grep ':80' # 找出运行在指定端口的进程
```

### 显示网络接口列表

```shell
netstat -i
netstat -ie # 显示详细信息
```

### IP和TCP分析

```shell
netstat -nat | grep "192.168.1.15:22" |awk '{print $5}'|awk -F: '{print $1}'|sort|uniq -c|sort -nr|head -20 # 查看连接某服务端口最多的的IP地址
netstat -nat | awk '{print $6}' # TCP各种状态列表
netstat -nat |awk '{print $6}'|sort|uniq -c # 先把状态全都取出来,然后使用uniq -c统计，之后再进行排序。
```
