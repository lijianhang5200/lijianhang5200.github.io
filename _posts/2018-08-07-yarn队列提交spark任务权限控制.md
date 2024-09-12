---
layout: post
category: 数据运维
title: "yarn队列提交spark任务权限控制"
tag: [spark]
excerpt: yarn队列提交spark任务权限控制。
---

## CapacityScheduler

### 模型介绍

```config
Capacity Scheduler是一个hadoop支持的可插拔的资源调度器, 它允许多租户安全的共享集群资源, 它们的applications在容量限制之下, 可以及时的分配资源。 使用操作友好的方式运行hadoop应用, 同时最大化吞吐能力和集群利用率。 
Capacity Scheduler提供的核心理念就是Queues（队列）, 这些queues通常有管理员设定。 为了在共享资源上, 提供更多的控制和预见性, Capacity Scheduler支持多级queue, 以确保在其他queues允许使用空闲资源之前, 资源可以在一个组织的sub-queues之间共享。
``` 

### 资源分配相关参数

```config
capacity: Queue的容量百分比, float类型, 例如12.5。 所有Queue的各个层级的capacity总和必须为100。 因为弹性资源分配, 如果集群中有较多的空闲资源, queue中的application可能消耗比此设定更多的Capacity。 
maximum-capacity:  queue capacity最大占比, float类型, 此值用来限制queue中的application的弹性的最大值。 默认为-1禁用“弹性限制”。 
minimum-user-limit-percent: 任何时间如果有资源需要, 每个queue都会对分配给一个user的资源有一个强制的限制, 这个user-limit可以在最大值和最小值之间。 此属性就是最小值, 其最大值依赖于提交applications的用户的个数。 例如: 假设此值为25, 如果有2个用户向此queue提交application, 那么每个用户最多消耗queue资源容量的50%；如果第三个user提交了application, 那么任何一个user使用资源容量不能超过queue的33%；4个或者更多的用户参与, 那么每个用户资源使用都不会超过queue的25%。 默认值为100, 表示对没有用户资源限制。 
user-limit-factor: queue容量的倍数, 用来设置一个user可以获取更多的资源。 默认值为1, 表示一个user获取的资源容量不能超过queue配置的capacity, 无论集群有多少空闲资源。 此值为float类型。 [最多仍不超过maximum-capacity]。
```

### 限制应用程序数目相关参数

```config
maximum-applications : 集群或者队列中同时处于等待和运行状态的应用程序数目上限, 这是一个强限制, 一旦集群中应用程序数目超过该上限, 后续提交的应用程序将被拒绝, 默认值为10000。 所有队列的数目上限可通过参数yarn.scheduler.capacity.maximum-applications设置（可看做默认值）, 而单个队列可通过参数yarn.scheduler.capacity..maximum-applications设置适合自己的值。 
maximum-am-resource-percent: 集群中用于运行应用程序ApplicationMaster的资源比例上限, 该参数通常用于限制处于活动状态的应用程序数目。 该参数类型为浮点型, 默认是0.1, 表示10%。 所有队列的ApplicationMaster资源比例上限可通过参数yarn.scheduler.capacity. maximum-am-resource-percent设置（可看做默认值）, 而单个队列可通过参数yarn.scheduler.capacity.. maximum-am-resource-percent设置适合自己的值。
``` 

### 队列访问和权限控制参数

```config
state : 队列状态可以为STOPPED或者RUNNING, 如果一个队列处于STOPPED状态, 用户不可以将应用程序提交到该队列或者它的子队列中, 类似的, 如果ROOT队列处于STOPPED状态, 用户不可以向集群中提交应用程序, 但正在运行的应用程序仍可以正常运行结束, 以便队列可以优雅地退出。 
acl_submit_applications: 限定哪些Linux用户/用户组可向给定队列中提交应用程序。 需要注意的是, 该属性具有继承性, 即如果一个用户可以向某个队列中提交应用程序, 则它可以向它的所有子队列中提交应用程序。 配置该属性时, 用户之间或用户组之间用“, ”分割, 用户和用户组之间用空格分割, 比如“user1, user2 group1,group2”。 
acl_administer_queue: 为队列指定一个管理员, 该管理员可控制该队列的所有应用程序, 比如杀死任意一个应用程序等。 同样, 该属性具有继承性, 如果一个用户可以向某个队列中提交应用程序, 则它可以向它的所有子队列中提交应用程序。
``` 

## 实例

### 配置

配置yarn-site.xml中的ResourceManager使用CapacityScheduler

```xml
<property>
  <name>yarn.resourcemanager.scheduler.class</name>
  <value>org.apache.hadoop.yarn.server.resourcemanager.scheduler.capacity.CapacityScheduler</value>
</property>
```

配置Queues

CapacityScheduler将会使用capacity-scheduler.xml作为queue配置文件。

```config
这里的配置项格式应该是yarn.scheduler.capacity.<queue-path>.queues，也就是这里的root是一个queue-path，因为这里配置了value是default，所以root这个queue-path只有一个队列叫做default，那么有关default的具体配置都是形如下的配置项: 
yarn.scheduler.capacity.root.default.capacity: 一个百分比的值，表示占用整个集群的百分之多少比例的资源，这个queue-path下所有的capacity之和是100
yarn.scheduler.capacity.root.default.user-limit-factor: 每个用户的低保百分比，比如设置为1，则表示无论有多少用户在跑任务，每个用户占用资源最低不会少于1%的资源
yarn.scheduler.capacity.root.default.maximum-capacity: 弹性设置，最大时占用多少比例资源
yarn.scheduler.capacity.root.default.state: 队列状态，可以是RUNNING或STOPPED
yarn.scheduler.capacity.root.default.acl_submit_applications: 哪些用户或用户组可以提交人物
yarn.scheduler.capacity.root.default.acl_administer_queue: 哪些用户或用户组可以管理队列
```

如果在运行时，添加了queue或者修改了ACLs，可按页面提示刷新。 但是删除Queue是不支持的，需要依次重启备用和活动的ResourceManager角色使配置生效。

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
<property>
  <name>yarn.scheduler.capacity.root.queues</name>
  <value>default,wa,yq</value>
</property>
<property>
  <name>yarn.scheduler.capacity.root.capacity</name>
  <value>100</value>
</property>
<property>
  <name>yarn.scheduler.capacity.root.acl_administer_queue</name>
  <value>admin</value>
</property>
<property>
  <name>yarn.scheduler.capacity.root.acl_submit_applications</name>
  <value>admin</value>
</property>
<property>
  <name>yarn.scheduler.capacity.root.default.capacity</name>
  <value>30</value>
</property>
<property>
  <name>yarn.scheduler.capacity.root.default.maximum-capacity</name>
  <value>35</value>
</property>
<property>
  <name>yarn.scheduler.capacity.root.wa.capacity</name>
  <value>45</value>
</property>
<property>
  <name>yarn.scheduler.capacity.root.wa.maximum-capacity</name>
  <value>50</value>
</property>
<property>
  <name>yarn.scheduler.capacity.root.yq.capacity</name>
  <value>25</value>
</property>
<property>
  <name>yarn.scheduler.capacity.root.yq.maximum-capacity</name>
  <value>30</value>
</property>
<property>
  <name>yarn.scheduler.capacity.root.wa.acl_administer_queue</name>
  <value>admin,user01</value>
</property>
<property>
  <name>yarn.scheduler.capacity.root.wa.acl_submit_applications</name>
  <value>admin,user01</value>
</property>
<property>
  <name>yarn.scheduler.capacity.root.yq.acl_administer_queue</name>
  <value>admin,user02</value>
</property>
<property>
  <name>yarn.scheduler.capacity.root.yq.acl_submit_applications</name>
  <value>admin,user02</value>
</property>
<property>
  <name>yarn.scheduler.capacity.resource-calculator</name>
  <value>org.apache.hadoop.yarn.util.resource.DominantResourceCalculator</value>
</property>
</configuration>
```

以上配置生效后可以进入Yarn Web UI页面查看，队列设置是否正确

**注意** 

1. 所有队列的capacity容量和为100%
2. 配置文件标红参数

**yarn.scheduler.capacity.root.acl_administer_queue**和**yarn.scheduler.capacity.root.acl_submit_applications**表示admin用户为根队列的超级用户，即可操作根队列下的所有子队列，这个两个参数必须设置，否则，对子队列设置的用户访问控制不会生效。

### 常见问题

#### 问题

IOException: Failed to send RPC 6958994327572625202 to /192.168.20.24:2592: java.nio.channels.ClosedChannelException

#### 解决

给yarn-site.xml增加配置

```xml
<property>
  <name>yarn.nodemanager.pmem-check-enabled</name>
  <value>false</value>
</property>
<property>
  <name>yarn.nodemanager.vmem-check-enabled</name>
  <value>false</value>
</property>
```

#### 参考文档

[https://www.cnblogs.com/xiaodf/p/6266201.html](https://www.cnblogs.com/xiaodf/p/6266201.html)
[https://blog.csdn.net/jiangjingxuan/article/details/54729091](https://blog.csdn.net/jiangjingxuan/article/details/54729091)
[https://hadoop.apache.org/docs/r2.4.1/hadoop-yarn/hadoop-yarn-site/CapacityScheduler.html](https://hadoop.apache.org/docs/r2.4.1/hadoop-yarn/hadoop-yarn-site/CapacityScheduler.html)
