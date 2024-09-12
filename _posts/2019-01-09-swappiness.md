---
layout: post
category: 运维
title:  "Linux swappiness参数设置"
tag: [linux]
excerpt: swappiness，Linux内核参数，控制换出运行时内存的相对权重。swappiness参数值可设置范围在0到100之间。 低参数值会让内核尽量少用交换，更高参数值会使内核更多的去使用交换空间。
---

## 摘要

swappiness，Linux内核参数，控制换出运行时内存的相对权重。swappiness参数值可设置范围在0到100之间。 低参数值会让内核尽量少用交换，更高参数值会使内核更多的去使用交换空间。

默认值为60（参考网络资料：当剩余物理内存低于40%（40=100-60）时，开始使用交换空间）。对于大多数操作系统，设置为100可能会影响整体性能，而设置为更低值（甚至为0）则可能减少响应延迟。

## 参数值说明

```shell
vm.swappiness = 0   # 仅在内存不足的情况下--当剩余空闲内存低于vm.min_free_kbytes limit时，使用交换空间。
vm.swappiness = 1   # 内核版本3.5及以上、Red Hat内核版本2.6.32-303及以上，进行最少量的交换，而不禁用交换。
vm.swappiness = 10  # 当系统存在足够内存时，推荐设置为该值以提高性能。
vm.swappiness = 60  # 默认值
vm.swappiness = 100 # 内核将积极的使用交换空间。
```

对于内核版本为3.5及以上，Red Hat内核版本2.6.32-303及以上，多数情况下，设置为1可能比较好，0则适用于理想的情况下（it is likely better to use 1 for cases where 0 used to be optimal）

## 修改swappiness的值

### 临时设置（重启后失效）

- 方法一
  ```shell
  sysctl -a | grep vm.swappiness # 查看现在值
  vm.swappiness = 30
  echo 10 > /proc/sys/vm/swappiness
  sysctl -a | grep vm.swappiness # 查看修改后值
  vm.swappiness = 10
  ```
  **注** 必须以root用户登录
- 方法二
  ```shell
  sysctl -w vm.swappiness=10
  vm.swappiness = 10
  cat /proc/sys/vm/swappiness # 查看修改后值
  10
  ```

### 永久设置

在/etc/sysctl.conf中编辑，增加如下参数（如果存在的话）

```shell
vim /etc/sysctl.conf
  vm.swappiness = 10
```
