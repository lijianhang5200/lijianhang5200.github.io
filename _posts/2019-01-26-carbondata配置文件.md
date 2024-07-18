---
layout: post
category: 数据运维
title: "CarbonData配置文件"
tag: [ hadoop ]
excerpt: 整理CarbonData配置文件所有配置项。
---

### 介绍

整理CarbonData配置文件所有配置项。

### carbon.properties

```shell
#################### 系统配置 ##################
##可选项。 carbondata将用它自己的格式创建存储并写入数据的位置。
##如果没有指定，将使用 spark.sql.warehouse.dir作为路径。
#carbon.storelocation
#数据文件的基础路径
#carbon.ddl.base.hdfs.url
#坏数据保存的路径, 默认值 /opt/Carbon/Spark/badrecords
#carbon.badRecords.location

#################### 性能配置 ##################
######## 数据加载期间配置 ########
#在排序期间使用的文件读取缓冲区大小(单位 MB) :MIN=1:MAX=100
carbon.sort.file.buffer.size=10
#在数据加载时要使用的核心数
carbon.number.of.cores.while.loading=2
#要排序并写入临时中间文件的记录数量
carbon.sort.size=100000
#用于hashmap的hashkey计算的算法
carbon.enableXXHash=true
#在合并排序期间启用数据预读取，同时从数据加载中的排序临时文件读取数据
#carbon.merge.sort.prefetch=true

######## 修改分区配置 ########
#更改分区时要使用的核心数
carbon.number.of.cores.while.alterPartition=2

######## 压缩配置 ########
#压缩时使用的核心数
carbon.number.of.cores.while.compacting=2
#对于较小的压缩, 配置第一阶段要合并的分段数量和第2阶段中要合并的压缩分段数。
carbon.compaction.level.threshold=4,3
#用于触发主要压缩默认大小(单位 MB)。
carbon.major.compaction.size=1024

#################### 额外配置 ##################
##配置输入数据的Timestamp数据类型的格式。
#carbon.timestamp.format=yyyy-MM-dd HH:mm:ss

######## 数据加载配置 ########
##排序期间使用的文件写入缓冲区大小。
#carbon.sort.file.write.buffer.size=16384
##表上数据加载的锁定机制。对于HDFS 可设置其值为 HDFSLOCK
##LOCALLOCK : 这种锁使用在文件被创建在本地文件系统上. 当只有一个Spark driver(thrift server)运行在一个机器上并且没有其他CardonData Spark应用在运行的情况，这种锁非常有用.
##HDFSLOCK : 这种锁使用在文件被创建在HDFS文件系统上. 当多个CardonData Spark应用在运行并且没有zookeeper在运行在这个集群并且HDFS支持基于文件的锁定时，这种锁非常有用。
#carbon.lock.type=LOCALLOCK
##合并后要开始排序的中间文件的最小数目。
#carbon.sort.intermediate.files.limit=20
##配置在carbon数据文件中的写入块元数据的保留的百分比空间
#carbon.block.meta.size.reserved.percentage=10
##读取csv文件缓冲区大小。
#carbon.csv.read.buffersize.byte=1048576
##对于读取用于最终合并的中间文件的线程数。
#carbon.merge.sort.reader.thread=3
##禁用/启用 carbon 块分区
#carbon.custom.block.distribution=false

######## 压缩配置 ########
##指定要从压缩中保留的分段数。
#carbon.numberof.preserve.segments=0
##在指定的天数内load data的segment将被合并。
#carbon.allowed.compaction.days=0
##在数据加载时启用压缩
#carbon.enable.auto.load.merge=false

######## 查询配置 ########
##执行一个查询所允许的最长时间。
#max.query.execution.time=60
##Min max feature is added to enhance query performance. To disable this feature, make it false.
#carbon.enableMinMax=true

######## 全局目录配置 ########
##The property to set the date to be considered as start date for calculating the timestamp.
#carbon.cutOffTimestamp
##The property to set the timestamp (ie milis) conversion to the SECOND, MINUTE, HOUR or DAY level.
#carbon.timegranularity=SECOND
##the number of prefetched rows in sort step
#carbon.prefetch.buffersize=1000

#################### 新增配置 ##################
######## 1.5.0新增配置 ########
##范围 10-1000 bytes
#carbon.minmax.allowed.byte.count=200 bytes (100 characters)	
##范围 NA
#carbon.insert.persist.enable=false
##范围 MEMORY_ONLY, MEMORY_AND_DISK, MEMORY_ONLY_SER(Java and Scala), MEMORY_AND_DISK_SER(Java and Scala), DISK_ONLY, MEMORY_ONLY_2, MEMORY_AND_DISK_2, OFF_HEAP(experimental)
##级别详情参考 http://spark.apache.org/docs/latest/rdd-programming-guide.html#rdd-persistence
#carbon.insert.storage.level=MEMORY_AND_DISK
##范围 MEMORY_ONLY, MEMORY_AND_DISK, MEMORY_ONLY_SER(Java and Scala), MEMORY_AND_DISK_SER(Java and Scala), DISK_ONLY, MEMORY_ONLY_2, MEMORY_AND_DISK_2, OFF_HEAP(experimental)
#carbon.update.storage.level=MEMORY_AND_DISK
##范围 MEMORY_ONLY, MEMORY_AND_DISK, MEMORY_ONLY_SER(Java and Scala), MEMORY_AND_DISK_SER(Java and Scala), DISK_ONLY, MEMORY_ONLY_2, MEMORY_AND_DISK_2, OFF_HEAP(experimental)
#carbon.global.sort.rdd.storage.level=MEMORY_ONLY

######## 1.5.1新增配置 ########
##范围 NA
#carbon.push.rowfilters.for.vector=false
##范围 1-4
#carbon.max.driver.threads.for.block.pruning=4

######## 1.5.2新增配置 ########
##范围 LOCAL_SORT, NO_SORT, GLOBAL_SORT, BATCH_SORT
#carbon.table.load.sort.scope=LOCAL_SORT
##范围 1-300
#carbon.range.column.scale.factor=3
```

### dataload.properties

```shell
#carbon 存储路径, 也可以在自己的机器上改变代码路径
carbon.storelocation=/home/david/Documents/carbondata/examples/spark2/target/store

#csv 分隔符
delimiter=,

#csv 引用符
#quotechar=\"

#csv 文件头
#fileheader=

#csv 数据转义符
#escapechar=\\

#csv 注释符
#commentchar=#

#column dictionary list
#columndict=

#null value's serialization format
#serialization_null_format=\\N

#bad records logger
#bad_records_logger_enable=false

#bad records action
#bad_records_action=force

#all dictionary folder path
#all_dictionary_path=

#complex column's level 1 delimiter
#complex_delimiter_level_1='\\\001'

#complex column's level 2 delimiter
#complex_delimiter_level_2='\\\002'

#timestamp数据类型所在列的格式
#dateformat=

#csv 数据是否支持多行
#multiline=false

#csv文件的最大列数
#maxColumns=
```
