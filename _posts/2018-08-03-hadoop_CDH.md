---
layout: post
category: 数据运维
title: "hadoop CDH搭建"
tag: [ hadoop ]
excerpt: CDH搭建。
---

## 软件版本

- hadoop-2.5.0-cdh5.3.6
- centos6.5 64-bit

## 伪分布式环境搭建:

### 创建用户(hadoop)

1. 添加用户

   ```shell
   useradd hadoop
   ```

2. 修改密码

   ```shell
   passwd hadoop
   ```

3. 赋予sudo权限

   ```shell
   chmod u+w /etc/sudoers
   vi /etc/sudoers
   hadoop ALL=(ALL) ALL(制表符分割)
   chmod u-w /etc/sudoers
   ```

### 修改主机名

```shell
hostname lvmama
vi /etc/sysconfig/network
  NETWORKING=yes
  HOSTNAME=lvmama
vi /etc/hosts
```

### 配置ssh免密码登录

```shell
ssh-keygen -t rsa
cat .ssh/id_rsa.pub >>.ssh/authorized_keys
chmod 600 .ssh/authorized_keys
ssh lvmama
```

### jdk安装

```shell
sudo mkdir /opt/softs/
sudo chown hadoop:hadoop /opt/softs/
tar -zxvf jdk
ln -s /opt/softs/jdk /opt/jdk
sudo vi /etc/profile
  export JAVA_HOME=/opt/jdk
  export CLASSPATH=.:$JAVA_HONE/lib
  export PATH=$PATH:$JAVA_HOME/bin
source /etc/profile
```

### hadoop安装

配置文档相关网址:

[http://archive.cloudera.com/cdh5/cdh/5/hadoop-2.5.0-cdh5.3.6/](http://archive.cloudera.com/cdh5/cdh/5/hadoop-2.5.0-cdh5.3.6/)

下载地址:

[http://archive.cloudera.com/cdh5/cdh/5/](http://archive.cloudera.com/cdh5/cdh/5/)

```shell
tar -zxvf hadoop
mkdir ~/hdfs
ln -s /opt/softs/hadoop* /opt/hadoop
vi $HADOOP_HOME/etc/hadoop/hadoop-env.sh
  export JAVA_HOME=/opt/jdk
  export HADOOP_PID_DIR=/data/hadoop/hdfs/tmp
  export HADOOP_LOG_DIR=/data/hadoop/logs
  export HADOOP_SSH_OPTS="-p 22"
vi $HADOOP_HOME/etc/hadoop/mapred-env.sh
  export HADOOP_MAPRED_PID_DIR=/home/hadoop/hdfs/tmp
vi $HADOOP_HOME/etc/hadoop/yarn-env.sh
  export YARN_PID_DIR=/home/hadoop/hdfs/tmp
vi $HADOOP_HOME/etc/hadoop/core-site.xml
  <configuration>
    <property>
      <name>fs.defaultFS</name>
      <value>hdfs://192.168.113.111:9000/</value>
    </property>
    <property>
      <name>hadoop.tmp.dir</name>
      <value>file://home/hadoop/hdfs/tmp</value>
    </property>
  </configuration>
vi $HADOOP_HOME/etc/hadoop/hdfs-site.xml
  <configuration>
    <property>
      <name>dfs.replication</name>
      <value>1</value>
    </property>
    <property>
      <name>dfs.namenode.name.dir</name>
      <value>file://home/hadoop/hdfs/name</value>
    </property>
    <property>
      <name>dfs.namenode.data.dir</name>
      <value>file://home/hadoop/hdfs/data</value>
    </property>
    <property>
      <name>dfs.permissions.enabled</name>
      <value>false</value>
    </property>
  </configuration>
cp $HADOOP_HOME/etc/hadoop/mapred-site.xml{.template,}
vi $HADOOP_HOME/etc/hadoop/mapred-site.xml
  <configuration>
    <property>
      <name>mapreduce.framework.name</name>
      <value>yarn</value>
    </property>
  </configuration>
vi $HADOOP_HOME/etc/hadoop/yarn-site.xml
  <configuration>
    <property>
      <name>yarn.nodemanager.aux-services</name>
      <value>mapreduce_shuffle</value>
    </property>
  </configuration>
vi $HADOOP_HOME/etc/hadoop/slaves(datanode相关)
  lvmama
sudo vi /etc/profile
  export HADOOP_HOME=/opt/hadoop
  export HADOOP_PREFIX=$HADOOP_HOME
  export HADOOP_COMMON_HOME=$HADOOP_PREFIX
  export HADOOP_CONF_DIR=$HADOOP_PREFIX/etc/hadoop
  export HADOOP_HDFS_HOME=$HADOOP_PREFIX
  export HADOOP_MAPRED_HOME=$HADOOP_PREFIX
  export HADOOP_YARN_HOME=$HADOOP_PREFIX
  export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
source /etc/profile
hadoop version
```

### 启动

```shell
hdfs namenode -format
start-all.sh(start-dfs.sh and start-yarn.sh)
```

### 验证是否成功

```shell
jps
1568 DataNode
1480 NameNode
1976 NodeManager
2137 Jps
1707 SecondaryNameNode
1884 ResourceManager
```
web界面:http://lvmama:50070

(外网需关闭防火墙)

关闭命令:service iptables stop

永久关闭防火墙:chkconfig iptables off

查看防火墙关闭状态:service iptables status

## 分布式安装

### 主机准备 centos6

```shell
vim /etc/hosts
  192.168.1.1   bigdata-01
  192.168.1.2   bigdata-02
  192.168.1.3   bigdata-03
```

### 关闭防火墙和SELINUX

```shell
setenforce 0
sed -i 's#SELINUX=enforcing#SELINUX=disabled#g' /etc/selinux/config
grep SELINUX=disabled /etc/selinux/config
# centos6
service iptables stop（关闭防火墙）
chkconfig iptables off（开机不自启动）
# centos7
systemctl disable firewalld.service
systemctl stop firewalld.service
systemctl status firewalld.service
```

### 免密钥登录（这个一定要, 不然你启动的时候, 老是要让你输入各种密码）

```shell
ssh-keygen -t rsa
ssh-copy-id bigdata-01 ; ssh-copy-id bigdata-02 ; ssh-copy-id bigdata-03
```

### 修改文件句柄数

```shell
vim /etc/security/limits.conf
#---------custom-----------------------
#
*           soft   nofile       240000
*           hard   nofile       655350
*           soft   nproc        240000
*           hard   nproc        655350
#-----------end-----------------------
source /etc/security/limits.conf
ulimit -n
24000
```

### ntp服务器同步时间

```shell
[root@bigdata-01 soft]# yum install ntp -y
cp -a /etc/ntp.conf{,.bak}
vim /etc/ntp.conf
  restrict default kod nomodify notrap nopeer noquery　 # restrict、default定义默认访问规则, nomodify禁止远程主机修改本地服务器
  restrict 127.0.0.1　　　　　　　　　　　                # 这里的查询是服务器本身状态的查询。
  restrict -6 ::1
  #server 0.centos.pool.ntp.org iburst          # 注掉官方自带的网络站点
  #server 1.centos.pool.ntp.org iburst
  #server 2.centos.pool.ntp.org iburst
  #server 3.centos.pool.ntp.org iburst
  server ntp1.aliyun.com                  # 目标服务器网络位置
  server 127.127.1.0      # local clock,当服务器与公用的时间服务器失去联系时, 就是连不上互联网时, 以局域网内的时间服务器为客户端提供时间同步服务。
  fudge  127.127.1.0 stratum 10
  # 如果计划任务有时间同步, 先注释, 两种用法会冲突。
crontab –e
  \*/30 * * * * /usr/sbin/ntpdate ntp1.aliyun.com > /dev/null 2>&1;/sbin/hwclock -w
systemctl start ntpd.service
systemctl enable ntpd.service
systemctl status ntpd.service
[root@bigdata-02 soft]# systemctl stop ntpd.service
[root@bigdata-02 soft]# systemctl disable ntpd.service
[root@bigdata-02 soft]# yum install ntpdate -y
[root@bigdata-02 soft]# /usr/sbin/ntpdate 192.168.1.1
[root@bigdata-02 soft]# crontab –e
  \*/30 * * * * /usr/sbin/ntpdate 192.168.1.1 > /dev/null 2>&1;/sbin/hwclock -w
systemctl restart crond.service
systemctl status crond.service
```

### jdk

```shell
echo -e "# java\nexport JAVA_HOME=/opt/jdk\nexport PATH=\${PATH}:\${JAVA_HOME}/bin:\${JAVA_HOME}/jre/bin\nexport CLESSPATH=.:\${JAVA_HOME}/lib:\${JAVA_HOME}/jre/lib" > /etc/profile
source /etc/profile
```

### zookeeper

```shell
echo  -e "\n# zookeeper\nexport ZK_HOME=/data/zookeeper\nexport PATH=\$PATH:\$ZK_HOME/bin" > /etc/profile
source /etc/profile
[root@bigdata-01 soft]# cp $ZK_HOME/conf/zoo_sample.cfg $ZK_HOME/conf/zoo.cfg
[root@bigdata-01 soft]# vim $ZK_HOME/conf/zoo.cfg
dataDir=/data/zookeeper/data
dataLogDir=/data/zookeeper/log
server.1=bigdata-01:2888:3888
server.2=bigdata-02:2888:3888
server.3=bigdata-03:2888:3888
分发并创建链接
[root@bigdata-01 soft]# echo 1 > /data/zookeeper/data/myid
[root@bigdata-02 soft]# echo 2 > /data/zookeeper/data/myid
[root@bigdata-03 soft]# echo 3 > /data/zookeeper/data/myid
[root@bigdata-* soft]# zkServer.sh start
```

### hadoop

```shell
[root@bigdata-* soft]# echo -e "# hadoop\nexport HADOOP_HOME=/opt/hadoop\nexport HADOOP_PREFIX=\$HADOOP_HOME\nexport HADOOP_COMMON_HOME=\$HADOOP_PREFIX\nexport HADOOP_CONF_DIR=\$HADOOP_PREFIX/etc/hadoop\nexport HADOOP_HDFS_HOME=\$HADOOP_PREFIX\nexport HADOOP_MAPRED_HOME=\$HADOOP_PREFIX\nexport HADOOP_YARN_HOME=\$HADOOP_PREFIX\nexport PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin" >> /etc/profile
[root@bigdata-* soft]# source /etc/profile
[root@bigdata-01 soft]# vim $HADOOP_HOME/etc/hadoop/hadoop-env.sh
  export JAVA_HOME=/opt/jdk
  export HADOOP_SSH_OPTS="-p 22"
[root@bigdata-01 soft]# vim $HADOOP_HOME/etc/hadoop/mapred-env.sh
  export JAVA_HOME=/opt/jdk
[root@bigdata-01 soft]# vim $HADOOP_HOME/etc/hadoop/yarn-env.sh
  export JAVA_HOME=/opt/jdk
```

```shell
[root@bigdata-01 soft]# vim $HADOOP_HOME/etc/hadoop/core-site.xml
```

```xml
<configuration>
<property>
  <name>fs.defaultFS</name>
  <value>hdfs://bigdata-01:9000/</value>
  <description>NameNode URI, 192.168.1.100为服务器IP地址, 其实也可以使用主机名</description>
</property>
<property>
  <name>hadoop.tmp.dir</name>
  <value>/data/hadoop/tmp</value>
</property>
<property>
  <name>hadoop.http.staticuser.user</name>
  <value>root</value>
</property>
<property>
  <name>ha.zookeeper.quorum</name>
  <value>bigdata-01:2181,bigdata-02:2181,bigdata-03:2181</value>
</property>
<property>
  <name>ha.zookeeper.session-timeout.ms</name>
  <value>10000</value>
</property>
<property>
  <name>fs.trash.checkpoint.interval</name>
  <value>1440</value>
  <discription>以分钟为单位的垃圾回收检查间隔。</discription>
</property>
<property>
  <name>hadoop.security.authentication</name>
  <value>simple</value>
  <discription>可以设置的值为 simple (无认证) 或者 kerberos（一种安全认证系统）</discription>
</property>
<property>
  <name>fs.trash.interval</name>
  <value>1440</value>
  <discription>以分钟为单位的垃圾回收时间, 垃圾站中数据超过此时间, 会被删除。如果是0, 垃圾回收机制关闭。</discription>
</property>
</configuration>
```

```shell
[root@bigdata-01 soft]# vim $HADOOP_HOME/etc/hadoop/hdfs-site.xml
```

```xml
<configuration>
<property>
  <name>dfs.replication</name>
  <value>2</value>
</property>
<property>
  <name>dfs.blocksize</name>
  <value>134217728</value>
</property>
<property>
  <name>dfs.permissions.enabled</name>
  <value>true</value>
  <description>true:权限检查, false：权限检查关闭,其他行为不变. 从一个参数值切换到另一个参数值不会改变模式、所有者或文件或目录组。</description>
</property>
<property>
  <name>dfs.namenode.name.dir</name>
  <value>/data/bigdata/hdfs/name</value>
  <discription>持久存储名字空间，事务日志的本地路径</discription>
</property>
<property>
  <name>dfs.datanode.data.dir</name>
  <value>/data/bigdata/hdfs/data</value>
  <discription>datanode存放数据的路径，单个节点单配，多个目录逗号分隔</discription>
</property>
<property>
  <name>dfs.datanode.max.transfer.threads</name>
  <value>16384</value>
  <discription>指定用于在DataNode间传输block数据的最大线程数</discription>
</property>
<property>
  <name>dfs.datanode.balance.bandwidthPerSec</name>
  <value>52428800</value>
  <description>Specifies the maximum amount of bandwidth that each datanode can utilize for the balancing purpose in term of the number of bytes per second.</description>
</property>
<property>
  <name>dfs.datanode.balance.max.concurrent.moves</name>
  <value>50</value>
  <description>增加DataNode上转移block的Xceiver的个数上限。</description>
</property>
<property>
  <name>dfs.nameservices</name>
  <value>ns1</value>
  <description>HDFS 命名服务的逻辑名称,可用户自己定义,比如 mycluster,注意,该名称将被基于 HDFS 的系统使用,比如 Hbase 等,此外,需要你想启用 HDFS Federation,可以通过该 参数指定多个逻辑名称,并用“,”分割。</description>
</property>
<property>
  <name>dfs.ha.namenodes.ns1</name>
  <value>nn1,nn2</value>
</property>
<property>
  <name>dfs.namenode.rpc-address.ns1.nn1</name>
  <value>bigdata-01:8020</value>
  <discription>nn1的RPC通信地址, nn1所在地址</discription>
</property>
<property>
  <name>dfs.namenode.http-address.ns1.nn1</name>
  <value>bigdata-01:50070</value>
  <discription>nn1的http通信地址, 外部访问地址</discription>
</property>
<property>
  <name>dfs.namenode.rpc-address.ns1.nn2</name>
  <value>bigdata-02:8020</value>
  <discription>nn2的RPC通信地址, nn2所在地址</discription>
</property>
<property>
  <name>dfs.namenode.http-address.ns1.nn2</name>
  <value>bigdata-02:50070</value>
  <discription>nn2的http通信地址, 外部访问地址</discription>
</property>
<property>
  <name>dfs.namenode.journalnode</name>
  <value>node1:8485;node2:8485;node3:8485</value>
  <discription>journalnode为了解决hadoop单点故障，给namenode做元数据同步的，奇数个,一般3个或5个</discription>
</property>
<property>
  <name>dfs.namenode.shared.edits.dir</name>
  <value>qjournal://${dfs.namenode.journalnode}/ns1</value>
  <description>指定NameNode的元数据在JournalNode日志上的存放位置(一般和zookeeper部署在一起)</description>
</property>
<property>
  <name>dfs.journalnode.edits.dir</name>
  <value>/data/hadoop/journal</value>
  <description>指定JournalNode在本地磁盘存放数据的位置</description>
</property>
<property>
  <name>dfs.client.failover.proxy.provider.ns1</name>
  <value>org.apache.hadoop.hdfs.server.namenode.ha.ConfiguredFailoverProxyProvider</value>
  <description>客户端通过代理访问namenode, 访问文件系统, HDFS 客户端与Active 节点通信的Java 类, 使用其确定Active 节点是否活跃</description>
</property>
<property>
  <name>dfs.ha.fencing.methods</name>
  <value>sshfence</value>
  <description>这是配置自动切换的方法, 有多种使用方法, 具体可以看官网, 在文末会给地址, 这里是远程登录杀死的方法, 这个参数的值可以有多种, 你也可以换成shell(/bin/true)试试, 也是可以的, 这个脚本do nothing 返回0</description>
</property>
<property>
  <name>dfs.ha.fencing.ssh.private-key-files</name>
  <value>/root/.ssh/id_rsa</value>
  <description>这个是使用sshfence隔离机制时才需要配置ssh免登陆</description>
</property>
<property>
  <name>dfs.ha.fencing.ssh.connect-timeout</name>
  <value>30000</value>
  <description>配置sshfence隔离机制超时时间, 这个属性同上, 如果你是用脚本的方法切换, 这个应该是可以不配置的</description>
</property>
<property>
  <name>dfs.ha.automatic-failover.enabled</name>
  <value>true</value>
  <description>开启自动故障转移, 如果你没有自动故障转移, 这个可以先不配</description>
</property>
</configuration>
```

```shell
[root@bigdata-01 soft]# vim $HADOOP_HOME/etc/hadoop/mapred-site.xml
```

```xml
<configuration>
<property>
  <name>mapreduce.framework.name</name>
  <value>yarn</value>
</property>
<property>
  <name>mapreduce.jobhistory.address</name>
  <value>bigdata-01:10020</value>
</property>
<property>
  <name>mapreduce.jobhistory.webapp.address</name>
  <value>bigdata-01:19888</value>
</property>
</configuration>
```

```shell
[root@bigdata-01 soft]# vim $HADOOP_HOME/etc/hadoop/yarn-site.xml
```

```xml
<configuration>
<property>
  <name>yarn.app.mapreduce.am.scheduler.connection.wait.interval-ms</name>
  <value>5000</value>
  <discription>schelduler失联等待连接时间</discription>
</property>
<property>
  <name>yarn.nodemanager.aux-services</name>
  <value>mapreduce_shuffle</value>
</property>
<property>
  <name>yarn.resourcemanager.connect.retry-interval.ms</name>
  <value>5000</value>
  <description>How often to try connecting to the ResourceManager.</description>
</property>
<property>
  <name>yarn.resourcemanager.ha.enabled</name>
  <value>true</value>
  <discription>是否启用RM HA，默认为false（不启用）</discription>
</property>
<property>
  <name>yarn.resourcemanager.ha.automatic-failover.enabled</name>
  <value>true</value>
  <discription>是否启用自动故障转移。默认情况下，在启用HA时，启用自动故障转移。</discription>
</property>
<property>
  <name>yarn.resourcemanager.ha.automatic-failover.embedded</name>
  <value>true</value>
  <discription>启用内置的自动故障转移。默认情况下，在启用HA时，启用内置的自动故障转移。</discription>
</property>
<property>
  <name>yarn.resourcemanager.cluster-id</name>
  <value>cluster1</value>
  <discription>集群的Id，elector使用该值确保RM不会做为其它集群的active。</discription>
</property>
<property>
  <name>yarn.resourcemanager.ha.rm-ids</name>
  <value>rm1,rm2</value>
  <discription>RMs的逻辑id列表,rm管理资源器；一般配两个，一个起作用  其他备用；用逗号分隔,如:rm1,rm2 </discription>
</property>
<property>
  <name>yarn.resourcemanager.hostname.rm1</name>
  <value>bigdata-01</value>
  <discription>RM的节点1的hostname</discription>
</property>
<property>
  <name>yarn.resourcemanager.scheduler.address.rm1</name>
  <value>${yarn.resourcemanager.hostname.rm1}:8030</value>
  <discription>RM对AM暴露的地址,AM通过地址想RM申请资源,释放资源等</discription>
</property>
<property>
  <name>yarn.resourcemanager.resource-tracker.address.rm1</name>
  <value>${yarn.resourcemanager.hostname.rm1}:8031</value>
  <discription>RM对NM暴露地址,NM通过该地址向RM汇报心跳,领取任务等</discription>
</property>
<property>
  <name>yarn.resourcemanager.address.rm1</name>
  <value>${yarn.resourcemanager.hostname.rm1}:8032</value>
  <discription>RM对客户端暴露的地址,客户端通过该地址向RM提交应用程序等</discription>
</property>
<property>
  <name>yarn.resourcemanager.admin.address.rm1</name>
  <value>${yarn.resourcemanager.hostname.rm1}:8033</value>
  <discription>RM对管理员暴露的地址.管理员通过该地址向RM发送管理命令等</discription>
</property>
<property>
  <name>yarn.resourcemanager.webapp.address.rm1</name>
  <value>${yarn.resourcemanager.hostname.rm1}:8088</value>
  <discription>RM对外暴露的web http地址，用户可通过该地址在浏览器中查看集群信息</discription>
</property>
<property>
  <description>The https adddress of the RM web application.</description>
  <name>yarn.resourcemanager.webapp.https.address.rm1</name>
  <value>${yarn.resourcemanager.hostname.rm1}:8090</value>
</property>
<property>
  <name>yarn.resourcemanager.hostname.rm2</name>
  <value>bigdata-02</value>
</property>
<property>
  <name>yarn.resourcemanager.scheduler.address.rm2</name>
  <value>${yarn.resourcemanager.hostname.rm2}:8030</value>
  </property>
<property>
  <name>yarn.resourcemanager.resource-tracker.address.rm2</name>
  <value>${yarn.resourcemanager.hostname.rm2}:8031</value>
</property>
<property>
  <name>yarn.resourcemanager.address.rm2</name>
  <value>${yarn.resourcemanager.hostname.rm2}:8032</value>
</property>
<property>
  <name>yarn.resourcemanager.admin.address.rm2</name>
  <value>${yarn.resourcemanager.hostname.rm2}:8033</value>
</property>
<property>
  <name>yarn.resourcemanager.webapp.address.rm2</name>
  <value>${yarn.resourcemanager.hostname.rm2}:8088</value>
</property>
<property>
  <name>yarn.resourcemanager.webapp.https.address.rm2</name>
  <value>${yarn.resourcemanager.hostname.rm2}:8090</value>
</property>
<property>
  <name>yarn.resourcemanager.recovery.enabled</name>
  <value>true</value>
  <discription>默认值为false，也就是说resourcemanager挂了相应的正在运行的任务在rm恢复后不能重新启动</discription>
</property>
<property>
  <name>yarn.resourcemanager.store.class</name>
  <value>org.apache.hadoop.yarn.server.resourcemanager.recovery.ZKRMStateStore</value>
  <discription>状态存储的类</discription>
</property>
<property>
  <name>ha.zookeeper.quorum</name>
  <value>node1:2181,node2:2181,node3:2181</value>
</property>
<property>
  <name>yarn.resourcemanager.zk-address</name>
  <value>${ha.zookeeper.quorum}</value>
  <discription>ZooKeeper服务器的地址（主机：端口号），既用于状态存储也用于内嵌的leader-election。</discription>
</property>
<property>
  <name>yarn.nodemanager.address</name>
  <value>${yarn.nodemanager.hostname}:8041</value>
  <discription>The address of the container manager in the NM.</discription>
</property>
<property>
  <name>yarn.log-aggregation-enable</name>
  <value>true</value>
</property>
  <property>
  <name>yarn.log-aggregation.retain-seconds</name>
  <value>106800</value>
</property>
</configuration>
```

```shell
[root@bigdata-01 soft]# vim $HADOOP_HOME/etc/hadoop/slaves
  bigdata-01
  bigdata-02
  bigdata-03
分发并创建链接
[root@bigdata-* soft]# $HADOOP_HOME/sbin/hadoop-daemon.sh start journalnode
[root@bigdata-01 soft]# hdfs namenode -format
[root@bigdata-01 soft]# hadoop-daemon.sh start namenode
[root@bigdata-02 soft]# hdfs namenode -bootstrapStandby
[root@bigdata-02 soft]# hadoop-daemon.sh start namenode
[root@bigdata-01 soft]# hdfs zkfc -formatZK
[root@bigdata-01 soft]# hadoop-daemon.sh start zkfc
[root@bigdata-01 soft]# start-dfs.sh
[root@bigdata-01 soft]# start-yarn.sh
[root@bigdata-03 soft]# yarn-daemon.sh start resourcemanager
验证高可用
  [root@bigdata-01 soft]# jps
  16704 JournalNode
  16288 NameNode
  16433 DataNode
  23993 QuorumPeerMain
  17241 NodeManager
  18621 Jps
  16942 DFSZKFailoverController
  [root@bigdata-01 soft]# kill -9 16288
```

## 启动命令(sbin目录下)

```shell
start-all.sh     # 启动所有的Hadoop守护进程。包括NameNode、 Secondary NameNode、DataNode、JobTracker、 TaskTrack
stop-all.sh     # 停止所有的Hadoop守护进程。包括NameNode、 Secondary NameNode、DataNode、JobTracker、 TaskTrack
start-dfs.sh     # 启动Hadoop HDFS守护进程NameNode、SecondaryNameNode和DataNode
stop-dfs.sh     # 停止Hadoop HDFS守护进程NameNode、SecondaryNameNode和DataNode
hadoop-daemons.sh start namenode       # 单独启动NameNode守护进程
hadoop-daemons.sh stop namenode       # 单独停止NameNode守护进程
hadoop-daemons.sh start datanode       # 单独启动DataNode守护进程
hadoop-daemons.sh stop datanode       # 单独停止DataNode守护进程
hadoop-daemons.sh start secondarynamenode   # 单独启动SecondaryNameNode守护进程
hadoop-daemons.sh stop secondarynamenode   # 单独停止SecondaryNameNode守护进程
start-mapred.sh 启动Hadoop MapReduce    # 守护进程JobTracker和TaskTracker
stop-mapred.sh 停止Hadoop MapReduce      # 守护进程JobTracker和TaskTracker
hadoop-daemons.sh start jobtracker       # 单独启动JobTracker守护进程
hadoop-daemons.sh stop jobtracker       # 单独停止JobTracker守护进程
hadoop-daemons.sh start tasktracker     # 单独启动TaskTracker守护进程
hadoop-daemons.sh stop tasktracker       # 单独启动TaskTracker守护进程

distribute-exclude.sh
  作用:将需要排除的datanode节点主机文件发布到所有NN机器上去。
  参数:
  前置条件:集群必须启动；需要在hdfs-site.xml文件中指定dfs.host.exclude,默认为空,如果需要,可以指定其他文件(绝对路径)。
httpfs.sh
  作用:启动/停止webhdfs,主要是提供一个基于HTTP的RESTful操作接口,基本包括hdfs文件系统的所有命令。
  参数:debug,start,stop等。
  前置条件:hdfs相关服务必须启动；需要在core-site.xml文件中指定hadoop.proxyuser.#suer#.hosts(代理用户可以代理的ip)和hadoop.proxyuser.#suer#.groups(代理用户所属组)。
hadoop-daemon.sh
  作用:启动/停止当前节点的hdfs相关的服务或者执行相应的脚本命令。
  命令格式:hadoop-daemon.sh [--config <conf-dir>] [--hosts hostlistfile] [-script script] (start/stop) (namenode|secondarynamenode|datanode|journalnode|dfs|dfsadmin|fsck|balancer|zkfc|其他)
yarn-daemon.sh
  作用:启动/停止当前节点的yarn相关的服务。
  命令格式:yarn-daemon.sh [--config <conf-dir>] [--hosts hostlistfile] (start/stop) (resourcemanager|nodemanager)
  注意:yarn-daemons.sh(多台机器)在yarn-daemon.sh(一台机器)的基础上,通知其他机器执行命令。
start-dfs.sh/stop-dfs.sh
  作用:启动/停止当前节点的hdfs相关的服务。
  命令格式:start-dfs.sh
  流程:调用hadoop-daemons.sh脚本启动namenode,datanode,secondarynamenode,zkfc。
start-yarn.sh/stop-yarn.sh
  作用:启动/停止当前节点的yarn相关的服务。
  命令格式:start-yarn.sh
  流程:调用yarn-daemons.sh脚本启动resourcemanager,nodemanager。
start-all.sh/stop-all.sh
  作用:启动/停止当前节点的hdfs和yarn相关的服务。
  命令格式:start-all.sh
  流程:调用start-dfs.sh/stop-dfs.sh和start-yarn.sh/stop-yarn.sh
```

## 操作命令

### hdfs命令

```config
用户命令:
  查看文件列表:    hdfs dfs -ls  /home/hadoop/aaron
  递归查看文件列表:  hdfs dfs -lsr   /home/hadoop/aaron
  创建文件目录:    hdfs dfs -mkdir /home/hadoop/aaron/newDir
                  -p递归创建
  删除文件:      hdfs dfs -rm  /home/hadoop/aaron/needDelete
  删除空目录:      hdfs dfs -rmdir   /home/hadoop/aaron
  递归删除目录:    hdfs dfs -rmr   /home/hadoop/aaron
  上传文件:      hdfs dfs –put   /home/hadoop/newFile /user/hadoop/aaron/
            hdfs dfs –copyFromLocal /home/hadoop/newFile /user/hadoop/aaron/
            hdfs dfs –moveFromLocal /home/hadoop/newFile /user/hadoop/aaron/
  下载文件:      hdfs dfs –get   /home/hadoop/aaron/newFile /home/hadoop/newFile
            hdfs dfs –copyToLocal /home/hadoop/newFile /user/hadoop/aaron/
            hdfs dfs –moveToLocal /home/hadoop/newFile /user/hadoop/aaron/
  查看文件:      hdfs dfs –cat   /home/hadoop/newFile
  解析文件:      hdfs dfs –text   /home/hadoop/newFile
  文件重命名:      hdfs dfs –mv  /home/hadoop/test.txt /home/hadoop/ok.txt
  查看命令详情:    hdfs dfs -help rm
管理员命令:
  检测磁盘异常信息:  hdfs fsck <path>
  动态刷新dfs.hosts和dfs.hosts.exclude配置:    hdfs dfsadmin -refreshNodes
  集群基本信息:    hdfs dfsadmin -report
  安全模式:      hdfs dfsadmin -safemode get/enter/leave
  查看namenode帮助:  hdfs namenode -h
  查看namenode帮助:  hdfs datanode -h
```

提交MAPREDUCE JOB:  hadoop jar /home/hadoop/job.jar \[jobMainClass] \[jobArgs]

### hadoop命令(主要是讲hdfs、yarn和mapred全部命令进行整合):

杀死某个JOB:    hadoop job -kill \[job-id]

### hdfs文件所属用户、所属组等读写执行控制权限

用下面的命令修改文件的权限、文件所有者，文件所属组：

```shell
groupadd Hadoop # 添加一个hadoop组
usermod -a -G Hadoop Larry # 将当前用户加入到hadoop组
vim /etc/sudoers # 将hadoop组加入到sudoer
  在 root ALL=(ALL) ALL 后加 Larry ALL=(ALL) ALL
```

修改hadoop目录的权限

```shell
chown -R Larry:Hadoop /home/Larry/Hadoop # <所有者:组 文件>
chmod -R 755 /home/Larry/Hadoop
```

修改hdfs的权限

```shell
hdfs dfs -chmod -R 755 /Larry
hdfs dfs -ls /
```

修改hdfs文件的所有者

```shell
sudo -u hdfs /data/hdfs/hadoop-2.7.3/bin/hdfs dfs -chown -R Larry /Larry
hdfs dfs -copyFromLocal <localsrc> URI # 拷贝本地文件到hdfs
hdfs dfs -cat file:///file3 /user/hadoop/file4#将路径指定文件的内容输出到stdout
hdfs dfs -chgrp [-R] GROUP URI # 改变文件的所属组
hdfs dfs -chmod [-R] 755 URI # 改变用户访问权限
hdfs dfs -chown [-R] [OWNER][:[GROUP]] URI [URI ] # 修改文件的所有者
hdfs dfs -copyToLocal URI localdst # 拷贝hdfs文件到本地
hdfs dfs -cp URI [URI …] <dest> # 拷贝hdfs文件到其它目录
hdfs dfs -du URI [URI …] # 显示目录中所有文件的大小
hdfs dfs -getmerge <src> <localdst> [addnl] # 合并文件到本地目录
```

## HDFS特性:

1. 高容错高可靠性
2. 高可扩展性
3. 高吞吐

### MapReduce结构:

### 开发环境搭建:

并行编程模型和计算框架,主要有resourcemanager和nodemanager两大类构成。

resourcemanager负责集群资源管理,nodemanager负责节点的资源管理。

运行MapReduce任务的时候,会产生ApplicationMaster和Container,ApplicationMaster负责向resourcemanager节点进行资源的申请并控制任务的执行,Container是最基本的资源单位,MapReduce的map和reduce均在其上运行。

### MapReduce编程思想

map负责将任务分解为多个任务,reduce负责将多个map任务的中间结果合并为最终结果map流程:

setup -> map ... map ... map ->cleanureduce流程:setup -> reduce ... reduce ... reduce ->cleanuMapReduce流程:input<k1,v1> -> map<k2,v2> -> shuffle<k2,list<v2,v2>> -> reduce<k3,v3> -> output

### 用户自定义数据类型:

用途:

1. 可以被序列化进行网络传输和文件存储
2. 在shuffle阶段进行大小比较

实现:

1. 采用hadoop的接口Writable
2. 采用java接口Comparable

hadoop将这两个接口结合提供了WritableComparable接口

内置数据类型:

1. MapWritable 
2. LongWritable 
3. IntWritable 
4. BooleanWritable 
5. ByteWritable
6. DoubleWritable 
7. FloatWritable 
8. Text 
9. NullWritable等

### 用户定制数据输入格式化器:

**InputFormat**: 描述MR作业的数据输入格式规范。

### MapReduce的数据输入格式:

TextInputFormat(lineRecordReader) (默认), KeyValueTextInputFormat, CombineTextInputFormat, SequenceFileInputFormat, DBInputFormat等。

### InputFormat详解:

**全称**: org.apache.hadoop.mapce.InputFormat

**方法**:

**getSplits**: 返回值是分片信息集合；作用:通过分片个数确定mapper的个数,根据分片信息中的数据地址信息决定是否采用数据本地化策略。

**createRecordReader**: 创建一个具体读取数据并构造key/value键值对的RecordReader实例对象。

### RecordReader详解:

**全称**: org.apache.hadoop.mapreduce.RecordReader

**方法**:

initialize:根据对应的分片信息进行初始化操作

nextKeyValue:是否有下一个键值对

getCurrentKey:获取当前key

getCurrentValue:获取当前Value

getProgress:进度信息

close:关闭资源读取相关连接

### shuffle阶段说明:

包括map阶段的combine(压缩), group, sort, partition以及reduce阶段的合并排序。 map阶段通过shuffle后会将输出数据按照reduce的分区分文件的保存, 文件内容是按照定义的sort进行排序好的, map阶段完成后会通知ApplicationMaster, 然后AM会通知reduce进行数据的拉起,在拉取过程中进行reduce端的shuffle过程。

### 用户自定义combiner:

实现类Reducer, 以map的输出作为combiner的输入key, value一致, 不一致不能直接使用。 job.setCombinerClass设置combiner的处理类, mapreduce框架不保证一定会调用该类的方法。


### 用户自定义Partitioner:

用于确定map输出的key、value对应的处理reduce的哪个节点。 默认mapreduce任务reduce个数为1, 此时partition其实没用效果, 但是当我们吧reduce个数修改为多个时partition就会决定key所对应的reduce的节点序号（从零开始）。 job.setPartitionerClass指定Partitioner类,默认情况下使用HashPartitioner.

### 用户自定义Group:

GroupingComparator是用于将map输出的<key,value>进行分组组合成<key,list<value>>

### 用户自定义sort:

SortComparator

### 用户自定义reduce的shuffle:

ShuffleComsumerPlugin

#### 问题总结:

#### 问题1

java.net.ConnectException: Call From DESKTOP-0Q62KM2/192.168.113.1 to 192.168.113.111:8020 failed on connection exception: java.net.ConnectException: Connection refused: no further information;

#### 解决

未解决

#### 问题

java.io.IOException: Incompatible clusterIDs in /home/hadoop/hdfs/tmp/dfs/data: namenode clusterID = CID-541d*; datanode clusterID = CID-7bc7*

#### 解决2

关闭集群,删除hdfs下所有文件,重新启动集群。

#### 问题3

java.io.FileNotFoundException: C:\Users\Àº½\AppData\Local\Temp\capture256.pro (系统找不到指定的路径。)

找不到或无法加载主类 hadoop.mr.wordcount.WordCountRunner

java.lang.NoClassDefFoundError: org/apache/hadoop/conf/Configuration

#### 解决

pom.xml 去除 <scope>provided</scope> （打包不加入jar包）

#### 问题

FATAL DataNode: Initialization failed for Block pool <registering> (Datanode Uuid unassigned) service to hadoop01/192.168.2.10:9000. Exiting.

#### 解决

删除hdfs下的所有文件，重新格式化

#### 问题

Unable to load native-hadoop library for your platform... using builtin-java classes where applicable

#### 解决

http://dl.bintray.com/sequenceiq/sequenceiq-bin/下载对应的编译版本 tar -xvf hadoop-native-64-*.tar -C /opt/hadoop/lib/native 会出现：java.lang.UnsatisfiedLinkError:org.apache.hadoop.util.NativeCrc32.nativeComputeChunkedSumsByteArray问题

#### 问题

MISSING 1 blocks of total size 135366 B

#### 解决

将丢失的块删除 hdfs fsck -delete