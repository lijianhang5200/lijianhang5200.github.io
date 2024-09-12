---
layout: post
category: 运维
title:  "linux crontab命令的使用"
tag: [linux]
excerpt: 周期性的执行某种任务或等待处理某些事件的一个守护进程。
---

## 简介

周期性的执行某种任务或等待处理某些事件的一个守护进程。

Linux下的任务调度分为两类, 系统任务调度和用户任务调度。

系统任务调度: 系统周期性所要执行的工作, 比如写缓存数据到硬盘、日志清理等。

在/etc目录下有一个crontab文件, 这个就是系统任务调度的配置文件。

用户任务调度: 用户定期要执行的工作, 比如用户数据备份、定时邮件提醒等。用户可以使用 crontab 工具来定制自己的计划任务。

## 格式

前五段是时间设定段, 第六段是要执行的命令段, 格式如下:

minute hour day month week command

其中: 

- **minute**

  表示分钟, 可以是从0到59之间的任何整数。

- **hour**

  表示小时, 可以是从0到23之间的任何整数。

- **day**

  表示日期, 可以是从1到31之间的任何整数。

- **month**

  表示月份, 可以是从1到12之间的任何整数。

- **week**

  表示星期几, 可以是从0到7之间的任何整数, 这里的0或7代表星期日。

- **command**

  要执行的命令, 可以是系统命令, 也可以是自己编写的脚本文件。

  在以上各个字段中, 还可以使用以下特殊字符:
 
- **星号（\*）**

  代表所有可能的值, 例如month字段如果是星号, 则表示在满足其它字段的制约条件后每月都执行该命令操作。

- **逗号（,）**

  可以用逗号隔开的值指定一个列表范围, 例如, “1,2,5,7,8,9”

- **中杠（-）**

  可以用整数之间的中杠表示一个整数范围, 例如“2-6”表示“2,3,4,5,6”

- **正斜线（/）**

  可以用正斜线指定时间的间隔频率, 例如“0-23/2”表示每两小时执行一次。同时正斜线可以和星号一起使用, 例如*/10, 如果用在minute字段, 表示每十分钟执行一次。

## 服务操作

```shell
yum install crontabs # 安装
/sbin/service crond start # 启动服务
/sbin/service crond stop # 关闭服务
/sbin/service crond restart # 重启服务
/sbin/service crond reload # 重新载入配置
/sbin/service crond status # 启动服务
ntsysv # 查看crontab服务是否已设置为开机启动
chkconfig –level 35 crond on # 加入开机自动启动
```

## 命令详解

```shell
crontab [-u user] file
crontab [-u user] [ -e | -l | -r ]
参数: 
-u user: 用来设定某个用户的crontab服务, 例如, “-u ixdba”表示设定ixdba用户的crontab服务, 此参数一般有root用户来运行。
file: file是命令文件的名字,表示将file做为crontab的任务列表文件并载入crontab。如果在命令行中没有指定这个文件, crontab命令将接受标准输入（键盘）上键入的命令, 并将它们载入crontab。
-e: 编辑某个用户的crontab文件内容。如果不指定用户, 则表示编辑当前用户的crontab文件。
-l: 显示某个用户的crontab文件内容, 如果不指定用户, 则表示显示当前用户的crontab文件内容。
-r: 从/var/spool/cron目录中删除某个用户的crontab文件, 如果不指定用户, 则默认删除当前用户的crontab文件。
-i: 在删除用户的crontab文件时给确认提示。
```
