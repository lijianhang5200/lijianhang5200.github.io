---
layout: post
category: 运维
title: "解决linux没有swap分区"
tag: [linux]
excerpt: 从阿里云购买的服务器没有swap分区。
---

## 摘要

从阿里云购买的服务器没有swap分区。

## 解决linux没有swap分区

1. 创建用于交换分区的文件
   ```shell
   dd if=/dev/zero of=/mnt/swap bs=block_size count=number_of_block
   ```
   注：block_size、number_of_block 大小可以自定义, 比如bs=1M count=1024 代表设置1G大小swap分区
2. 设置交换分区文件
   ```shell
   mkswap /mnt/swap
   chmod 600 /mnt/swap # 修改权限
   ```
3. 立即启用交换分区文件
   ```shell
   swapon /mnt/swap
   ```
   如果在/etc/rc.local中有swapoff -a 需要修改为swapon -a 
4. 设置开机时自启用swap分区
   需要修改文件中的swap行。
   ```shell
   vi /etc/fstab
   /mnt/swap swap swap defaults 0 0
   ```
   注：/mnt/swap 路径可以修改, 可以根据创建的swap文件具体路径来配置。
5. /proc/sys/vm/swappiness 配置对 SWAP 分区的使用原则
   当 swappiness 内容的值为 0 时, 表示最大限度地使用物理内存, 物理内存使用完毕后, 才会使用 SWAP 分区。当 swappiness 内容的值为 100 时, 表示积极地使用 SWAP 分区, 并且把内存中的数据及时地置换到 SWAP 分区。
   若需要永久修改此配置, 在系统重启之后也生效的话, 可以修改 /etc/sysctl.conf 文件, 并增加以下内容：

```shell
vim /etc/sysctl.conf
vm.swappiness=10
```

## 删除swap分区

```shell
swapoff /mnt/swap
```
