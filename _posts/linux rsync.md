---
layout: post
category: 运维
title: "linux rsync 命令的使用"
tag: [ linux ]
excerpt: 一款开源的、快速的、多功能的、可实现全量或增量的本地或者远程数据镜像同步复制、备份的优秀工具。
---

## 介绍

### 什么是Rsync

Rsync 即 Remote Rynchronization，是一款开源的、快速的、多功能的、可实现全量或增量的本地或者远程数据镜像同步复制、备份的优秀工具。

类似于scp命令，但是优于scp，可以做增量的备份。Rsync还可以在本地主机的不同分区或目录之间全量及增量的复制数据，这类似与cp命令，同样优于cp命令（增量）。

Rsync 是一个远程数据同步工具，可通过 LAN/WAN 快速同步多台主机间的文件。

Rsync 使用所谓的“Rsync 演算法”来使本地和远程两个主机之间的文件达到同步，这个算法只传送两个文件的不同部分，而不是每次都整份传送，因此速度相当快。

运行 Rsync server 的机器也叫 backup server，一个 Rsync server 可同时备份多个 client 的数据；也可以多个Rsync server 备份一个
client 的数据。

Rsync 可以搭配 rsh 或 ssh 甚至使用 daemon 模式。Rsync server 会打开一个873的服务通道（port），等待对方（客户端） Rsync
连接。连接时，Rsync server 会检查口令是否相符，若通过口令查核，则可以开始进行文件传输。第一次连通完成时，会把整份文件传输一次，下一次就只传送二个文件之间不同的部份。

### 特性

支持拷贝特殊文件如链接、设备等

支持排除特定文件或目录同步的功能，相当于打包命令tar的排除功能。

支持保持源文件或目录的权限、时间、软硬链接、属主属组等所有属性的不改变。

支持实现增量同步，既只同步发生变化的数据，因为数据传输效率很高。

支持使用rcp、rsh、ssh等方式配合传输文件，也可以直接通过socket（进程方式）传输。

支持匿名的或认证（无需系统用户）的进程模式传输，可实现方便安全的进行数据备份及镜像。

## 配置

### 安装

一般的linux系统上都默认安装得了rsync 。如若没有安装请自行安装。

```shell
yum install rsync
```

### 主要配置文件

rsyncd.conf(主配置文件)、rsyncd.secrets(密码文件)

rsyncd.conf 服务器的主要配置文件：

```shell
transfer logging = true
log format = %h %o %f %l %b
log file = /wy/logs/rsyncd.log
pid file = /var/run/rsyncd.pid
[data]
    path = /wy/data/doc
    comment = wydoc
    ignore errors = yes
    read only = no
    uid = root
    gid = root
    list = no
    hosts allow = 115.182.93.132  10.200.93.132
    hosts deny = *
    max connections = 10
    auth users = wy
    secrets file = /etc/rsyncd.secrets
    exclude =  dir1/  dir2/
```

配置文件解释

```shell
auth users是必须在服务器上存在的真实的系统用户，如果你想用多个用户以,号隔开，比如auth users = nobody,root

#在rsync 服务器中，全局定义有几个比较关健的，根据我们前面所给的配置文件 rsyncd.conf 文件；
　　pid file = /var/run/rsyncd.pid   注：告诉进程写到 /var/run/rsyncd.pid 文件中；
　　port = 873  注：指定运行端口，默认是873，您可以自己指定；
　　address = 192.168.1.171  注：指定服务器IP地址
　　uid = nobody  
　　gid = nobdoy 
　　注：服务器端传输文件时，要发哪个用户和用户组来执行，默认是nobody。 如果用nobody 用户和用户组，可能遇到权限问题，有些文件从服务器上拉不下来。所以我就偷懒，为了方便，用了root 。不过您可以在定义要同步的目录时定义的模块中指定用户来解决权限的问题。
　　
    use chroot = yes
　　注：用chroot，在传输文件之前，服务器守护程序在将chroot 到文件系统中的目录中，这样做的好处是可能保护系统被安装漏洞侵袭的可能。缺点是需要超级用户权限。另外对符号链接文件，将会排除在外。也就是说，你在 rsync服务器上，如果有符号链接，你在备份服务器上运行客户端的同步数据时，只会把符号链接名同步下来，并不会同步符号链接的内容；这个需要自己来尝试
 
　　read only = yes
　　注：read only 是只读选择，也就是说，不让客户端上传文件到服务器上。还有一个 write only选项，自己尝试是做什么用的吧；
 
　　#limit access to private LANs
　　hosts allow=192.168.1.0/255.255.255.0 10.0.1.0/255.255.255.0
　　注：在您可以指定单个IP，也可以指定整个网段，能提高安全性。格式是ip 与ip 之间、ip和网段之间、网段和网段之间要用空格隔开；
 
　　max connections = 5  
　　注：客户端最多连接数
 
　　motd file = /etc/rsyncd/rsyncd.motd
　　注：motd file 是定义服务器信息的，要自己写 rsyncd.motd 文件内容。当用户登录时会看到这个信息。
 
　　log file = /var/log/rsync.log
　　注：rsync 服务器的日志； 
 
　　transfer logging = yes
　　注：这是传输文件的日志
 
　　log format = %t %a %m %f %b
　　syslog facility = local3
　　timeout = 300
  
模块定义
　　模块定义什么呢？主要是定义服务器哪个目录要被同步。每个模块都要以[name]形式。这个名字就是在rsync 客户端看到的名字，其实有点象Samba服务器提供的共享名。而服务器真正同步的数据是通过path 指定的。我们可以根据自己的需要，来指定多个模块。每个模块要指定认证用户，密码文件、但排除并不是必须的 
　　下面是前面配置文件模块的例子：
 
　　[home]  #模块它为我们提供了一个链接的名字，在本模块中链接到了/home目录；要用[name] 形式
　　path = /usr/local/tomcat/webapp/home/statics    #指定文件目录所在位置，这是必须指定的
　　auth users = root   #认证用户是root  ，是必须在服务器上存在的用户
　　list=yes   #list 意思是把rsync 服务器上提供同步数据的目录在服务器上模块是否显示列出来。默认是yes 。如果你不想列出来，就no ；如果是no是比较安全的，至少别人不知道你的服务器上提供了哪些目录。你自己知道就行了；
　　ignore errors  #忽略IO错误
　　secrets file = /etc/rsyncd.secrets   #密码存在哪个文件
　　comment = linuxsir home  data  #注释可以自己定义
　　exclude = dir1/ dir2/     
　　注：exclude是排除的意思，也就是说，要把/usr/local/tomcat/webapp/home/statics目录下的easylife和samba排除在外； dir1/和dir2/目录之间有空格分开
```

rsyncd.secrets

```shell
#目录、用户权限创建配置
[root@Rsync_A ~]# useradd rsync -s /sbin/nologin -M
[root@Rsync_A ~]# grep rsync /etc/passwd
rsync:x:502:502::/home/rsync:/sbin/nologin#修改属主
[root@Rsync_A ~]# chown rsync.rsync /skyex/
[root@Rsync_A ~]# ls -ld /skyex/
drwxr-xr-x 2 rsync rsync 167936 May 30 22:10 /skyex/
#配置密码文件（格式---> 用户：密码）
[root@Rsync_A ~]# echo "rsync_backup:skyex" >> /etc/rsyncd.secrets
[root@Rsync_A ~]# cat /etc/rsyncd.secrets
rsync_backup:skyex
#修改权限更改密码文件权限600
[root@Rsync_A ~]# chmod 600 /etc/rsyncd.secrets
[root@Rsync_A ~]# ls -ld /etc/rsyncd.secrets
-rw------- 1 root root 19 May 27 22:14 /etc/rsyncd.secrets
```

### 启动Rsync服务

```shell
#启动rsync
[root@Rsync_A ~]# rsync --daemon
#查看rsync进程
[root@Rsync_A ~]# ps -ef | grep rsync
root 2779 1 0 22:41 ? 00:00:00 rsync --daemon
root 2785 2678 0 22:41 pts/0 00:00:00 grep rsync
#根据端口查看进程
[root@Rsync_A ~]# lsof -i tcp:873
COMMAND PID USER FD TYPE DEVICE SIZE/OFF NODE NAME
rsync 2779 root 4u IPv4 8610 0t0 TCP *:rsync (LISTEN)
[root@Rsync_A ~]# netstat -lntup | grep 873
tcp 0 0 0.0.0.0:873 0.0.0.0:* LISTEN 2779/rsync
```

### 客户端配置

```shell
#配置密码文件
[root@Rsync_B ~]# echo "skyex">>/etc/rsync.secrets
[root@Rsync_B ~]# cat /etc/rsync.secrets
skyex
#更改密码文件权限为600
[root@Rsync_B ~]# chmod 600 /etc/rsync.secrets
[root@Rsync_B ~]# ls -ld /etc/rsync.secrets
-rw------- 1 root root 6 May 27 22:17 /etc/rsync.secrets
```

## 基本语法

1. 本地到本地：rsync [OPTION] [SRC] [DEST]
2. 本地到远程：rsync [OPTION] [SRC] USER@:[DEST]
3. 远程到本地：rsync [OPTION] USER@:[SRC] [DEST]

```shell
OPTION  表示命令的选项
SRC     表示源地址
DEST    表示目标地址
USER    表示远程主机用户名
HOST    表示远程主机
```

### 常用选项

- -v或-verbose：在传输过程中提供更详细的输出。
- -a或-archive：归档模式，传输过程中包括递归复制和保存文件权限、时间戳、符号链接和设备文件。
- -r或-recursive：递归复制目录中的文件。
- -delete：文件或目录在源地址中不存在，但在目标中已存在，则删除。
- –exclude=[PATTERN]：排除与指定模式匹配的文件或目录。
- –include=[PATTERN]：包含与指定模式匹配的文件或目录。
- -z或-compress：在传输过程中压缩文件数据以减少带宽使用。
- –dry-run：执行试运行而不进行任何实际更改。
- –temp-dir：指定存储临时文件的目录。
- -u或–update：跳过目标目录中比源文件新的文件，以便仅更新较旧的文件。
- -h或–human-readable：以人类可读的格式输出数字。
- -i或–itemize-changes：输出传输过程中所做更改的列表。
- –progress：在传输过程中显示进度条。
- –stats：完成后提供文件传输统计信息。
- -e或–rsh=[COMMAND]：指定要使用的远程 shell。
- –bwlimit=[RATE]：限制带宽以提高网络效率。
- -P或–partial –progress：保留部分传输的文件并显示进度。
- -q或--quiet：抑制信息输出。
- --max-size：指定传输的大小限制。
- --remove-source-files：传输完成后删除源地址文件或目录。
- --backup：备份文件操作。
- --backup-dir：指定备份存储的目录

## 用法示例

在本地复制或同步文件

```shell
rsync -zvh abc.tar.gz /tmp/backups/
```

在本地复制或同步目录

```shell
rsync -avzh /root/abc /tmp/backups/
```

从本地复制文件到远程主机

```shell
rsync -avzh /root/abc root@abc:/root/
```

从远程主机复制文件到本地

```shell
rsync -avzh root@abc:/root/abc /tmp/abc
```

使用SSH将文件从远程主机复制到本地

```shell
rsync -avzhe ssh root@abc:/root/abc /tmp
```

使用SSH将文件从本地复制到远程主机

```shell
rsync -avzhe ssh /tmp root@abc:/root/abc
```

使用SSH传输时指定端口

```shell
rsync -a -e "ssh -p 2322" /opt/media/ root@abc:/opt/media/
```

传输过程中显示进度条

```shell
rsync -avzhe ssh --progress /root/abc root@abc:/root/abc
```

只复制指定的文件

```shell
rsync -avz --include='*.txt' /abc root@abc:/root/abc/
```

排除指定的文件

```shell
rsync -avz --exclude='*.ext' /abc root@abc:/root/abc/
```

包含和排除同时使用

```shell
rsync -avze ssh --include '.txt' --exclude '.obj' root@abc:/var/lib/ /root/abc
```

传输过程中删除目标地址存在，但源地址中不存在的文件

```shell
rsync -avz --delete root@abc:/var/lib/abc/ /root/abc/
```

设置传输文件大小限制

单位：K、M、G

```shell
rsync -avzhe ssh --max-size='200K' /var/lib/abc/ root@abc:/root/abc
```

传输完成后自动删除源地址中的文件或目录

```shell
rsync --remove-source-files -zvh backup.tar.gz root@abc:/tmp/backups/
```

模拟传输过程，不会对文件进行更改。

```shell
rsync --dry-run --remove-source-files -zvh backup.tar.gz root@abc:/tmp/backups/
```

设置传输的带宽限制

```shell
rsync --bwlimit=100 -avzhe ssh  /var/lib/abc/  root@abc:/root/tmp/
```

查看rsync的版本

```shell
rsync --version
```

递归复制目录中的文件

```shell
rsync -r abc/ duplicate/
```

创建一个备份

备份时会生成增量文件列表，并在原始文件名后附加波形符 (~)

```shell
rsync -av --backup --backup-dir=/path/to/backup/ original/ duplicate/
```
