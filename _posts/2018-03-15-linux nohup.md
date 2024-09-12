---
layout: post
category: 运维
title:  "linux nohup命令的使用"
tag: [linux]
excerpt: 不挂断地运行命令。
---

## 语法

```shell
nohup (选项) (参数)
```

## 用途：

不挂断地运行命令。

## 选项

```shell
--help：在线帮助；
--version：显示版本信息。
```

## 参数

程序及选项：要运行的程序及选项。

## 实例

使用nohup命令提交作业，如果使用nohup命令提交作业，那么在缺省情况下该作业的所有输出都被重定向到一个名为nohup.out的文件中，除非另外指定了输出文件：

```shell
nohup command > myout.file 2>&1 &
nohup ./xx.sh &	//使程序后台运行
```
