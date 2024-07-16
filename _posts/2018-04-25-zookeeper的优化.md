---
layout: post
category: 数据运维
title: "zookeeper的优化"
tag: [hadoop]
excerpt: zookeeper的优化。
---

## 运行调优

1. **快照文件和事务日志文件分别挂在不同磁盘。**

   zoo.cfg文件中, dataDir是存放快照数据的, dataLogDir是存放事务日志的。 zookeeper更新操作过程：先写事务日志, 再写内存, 周期性落到磁盘(刷新内存到快照文件)。 事务日志的对写请求的性能影响很大, 保证dataLogDir所在磁盘性能良好、没有竞争者。

2. **默认jvm没有配置Xmx、Xms等信息, 可以在conf目录下创建java.env文件**

   (内存堆空间一定要小于机器内存, 避免使用swap)

   ```shell
   export JVMFLAGS="-Xms2048m -Xmx2048m $JVMFLAGS"
   ```

3. **按天出zookeeper日志, 避免zookeeper.out文件过大。**

   zkEnv.sh文件日志输出方式从CONSOLE改为ROLLINGFILE；

   ```shell
   if [ "x${ZOO_LOG4J_PROP}" = "x" ]
   then
   #   ZOO_LOG4J_PROP="INFO,CONSOLE"
       ZOO_LOG4J_PROP="INFO,ROLLINGFILE"
   fi
   ```

   conf/log4j.properties设置为按天生成文件DailyRollingFileAppender

   ```shell
   #zookeeper.root.logger=INFO, CONSOLE
   zookeeper.root.logger=INFO, ROLLINGFIL
   log4j.appender.ROLLINGFILE=org.apache.log4j.DailyRollingFileAppender
   log4j.appender.ROLLINGFILE.Threshold=${zookeeper.log.threshold}
   log4j.appender.ROLLINGFILE.File=${zookeeper.log.dir}/${zookeeper.log.file}
   log4j.appender.ROLLINGFILE.DatePattern='.'yyyy-MM-dd

   # Max log file size of 10MB
   #log4j.appender.ROLLINGFILE.MaxFileSize=10MB
   ```

4. **zoo.cfg文件中skipACL=yes**

   忽略ACL验证, 可以减少权限验证的相关操作, 提升一点性能。

5. **zoo.cfg文件中forceSync=no**

   这个对写请求的性能提升很有帮助, 是指每次写请求的数据都要从pagecache中固化到磁盘上, 才算是写成功返回。 当写请求数量到达一定程度的时候, 后续写请求会等待前面写请求的forceSync操作, 造成一定延时。 如果追求低延时的写请求, 配置forceSync=no, 数据写到pagecache后就返回。 但是机器断电的时候, pagecache中的数据有可能丢失。

   默认为forceSync=yes, 为yes可以设置fsync.warningthresholdms=50 如果数据固化到磁盘的操作fsync超过50ms的时候, 将会在zookeeper.out中输出一条warn日志(forceSync=yes有效)。

6. **globalOutstandingLimit=100000**

   客户端连接过多, 限制客户端请求, 避免OOM

7. **zoo.cfg文件中preAllocSize=64M**

   日志文件预分配大小; snapCount=100,000 多少次写事务, 生成一个快照如果快照生成频繁可适当调大该参数。

   一般zk的应用提倡读大于写, 性能较好(10:1), 存储元数据用来协调分布式数据最终一致。写过于频繁使用缓存更好

8. **日志文件自动清除(如果追求性能, 可手动清除)**

   autopurge.snapRetainCount=3 # 在dataDir中保留的快照数量。

   autopurge.purgeInterval=24 # Purge task interval in hours Set to "0" to disable auto purge feature

9. **Server的自检恢复**

   ZK运行过程中, 如果出现一些无法处理的异常, 会直接退出进程, 也就是所谓的快速失败（fail fast）模式。

   由于zookeeper具有过半存活即可用的特性, 使得集群中少数机器down掉后, 整个集群还是可以对外正常提供服务的。 另外, 这些down掉的机器重启之后, 能够自动加入到集群中, 并且自动和集群中其它机器进行状态同步（主要就是从Leader那里同步最新的数据）, 从而达到自我恢复的目的。

   因此, 我们很容易就可以想到, 是否可以借助一些工具来自动完成机器的状态检测与重启工作。回答是肯定的, 这里推荐两个工具： Daemontools(http://cr.yp.to/daemontools.html) 和 SMF（http://en.wikipedia.org/wiki/Service_Management_Facility）, 能够帮助你监控ZK进程, 一旦进程退出后, 能够自动重启进程, 从而使down掉的机器能够重新加入到集群中去。

## 参数调优

```config
tickTime=2000 # 心跳间隔, 以毫秒为单位。
initLimit=10 # follower服务器(F)与leader服务器(L)之间初始连接时能容忍的最多心跳数（tickTime的数量）。
syncLimit=5 # follower服务器与leader服务器之间请求和应答之间能容忍的最多心跳数
dataDir=/var/lib/zookeeper # 数据文件目录
dataLogDir=/var/lib/zookeeper # 日志文件目录
clientPort=2181 # 客户端连接端口
maxClientCnxns=60
minSessionTimeout=4000
maxSessionTimeout=40000
autopurge.purgeInterval=24
autopurge.snapRetainCount=5
server.1=cdh-slave3:3181:4181 # 服务器名称与地址：格式（服务器编号=服务器地址:LF通信端口:选举端口）
server.2=cdh-master:3181:4181
server.3=cdh-slave2:3181:4181
leaderServes=yes
```
