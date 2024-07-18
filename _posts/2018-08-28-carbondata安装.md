---
layout: post
category: 数据运维
title: "carbondata安装"
tag: [ hadoop ]
excerpt: 一种新的高性能数据存储格式，针对当前大数据领域分析场景需求各异而导致的存储冗余问题。
---

## 摘要

Apache CarbonData是一种新的高性能数据存储格式，针对当前大数据领域分析场景需求各异而导致的存储冗余问题，CarbonData提供了一种新的融合数据存储方案，以一份数据同时支持“任意维度组合的过滤查询、快速扫描、详单查询等”多种应用场景，并通过多级索引、字典编码、列存等特性提升了IO扫描和计算性能，实现百亿数据级秒级响应。

## 介绍

CarbonData支持完整的标准SQL支持，以及多种分析场景的支持,“一份数据支持多种使用场景”，例如大规模扫描和计算的批处理场景，OLAP多维交互式分析场景，明细数据即席查询，主键低时延点查，以及对实时数据的实时查询等场景主要概括为一下几种

- 支持海量数据扫描提取其中某些列；
- 支持根据主键进行查找的低于秒级响应；
- 支持海量数据进行交互式查询的秒级响应；
- 支持快速地抽取单独记录，并且从该记录中获取到所有列信息；
- 支持HDFS，可以与Hadoop集群进行很好的无缝兼容。

## 原理

CarbonData 原理介绍分为三部分，第一部分是数据组织介绍，第二部分是索引，第三部分是扫描数据。

### 文件格式

- 数据分布
  - Block: 一个HDFS文件，256M
  - Blocklet： 文件内的列存数据块是最小的IO读取单元
  - Column chunk: Blocklet内的列数据
  - Page: Column chunk 内的数据页，是最小解码单元
- 源数据信息
  - Header: Version, Schema
  - Footer: Blocklet Offset, Index & 文件级统计信息
- 内置索引和统计信息
  - Blocklet索引: B Tree startkey,endkey
  - Blocklet级和Page级统计信息: min, max等

![文件格式](assets/images/carbondata文件格式.jpeg)

上图右侧为 CarbonData 内部的文件格式，有 file header、有 file footer、有记录元数据中心，包括 schema 数据、偏移量数据等。我们重点看一下中间的 Blocklet 内容，Blocklet 是数据文件内的一个列存数据块。Blocklet 内部按列存储，比如说有 column 1 chunk、colume 2 chunk，每一列数据又分为 page，page 是最小的解码单元。另外一个特点是除了元数据信息以外，还有索引信息。索引信息被统一存在 Footer 内，它包括了 Blocklet 的索引，即主索引，它是 B 树里面所包含的 start key 和 end key 之间的范围值。同时也包括 Blocklet 级和 page 级统计信息，这些统计信息是非常有用的，通过这些信息可以跳过 Blocklet 和 page，避免不必要的 IO 和解码。

### 利用两级索引

- 第一级: 文件级索引

  用于过滤文件(HDFS Block), 避免扫描不必要的文件, 减少多达95%的Spark Task

- 第二级: Blocklet索引

  用于过滤文件内部的Blocklet, 避免扫描不必要的Blocklet, 减少磁盘IO

Spark 分成 Driver 和 Executor，与 CarbonData 相对应以实现两极的索引。在 Driver 侧，Spark 可以对每一个 Blocklet 文件进行过滤，以此得到它需要扫描的文件。很多情况下，我们可以在 Driver 侧就减少掉 95% 不必要的 Spark task，避免扫描不必要的文件, 当需要扫描的文件找到之后，Spark 便会下发 task。在 Executor 侧也会利用 Blocklet 索引去过滤文件内部的在 Driver 侧以减少磁盘 IO。

### 扫描优化

- 大颗粒IO单元(Carbon V3格式)

  Blocklet内部一个Column Chunk是一个IO单元, Blocklet按大小切分, 默认64MB, 大概有100万行记录, 大颗粒顺序读提升扫描性能。

- 跳跃解码(Carbon V3格式) 

  增加数据页Page概念, 按Page进行过滤和解码, 减少不必要的解码解压缩, 提升CPU利用率。

- 向量化解码 + Spark向量化处理 

  解码和解压缩采用向量化处理, 与Spark2.1向量化、Codegen结合, 在扫描 + 聚合场景下提升性能4X

- 堆外内存 

  处理大数据集时, 解码压缩过程堆外完成, 减少GC。

Spark2.0 之后有 whole stage 、whole job 和向量化，它在计算层有很好的技术，在存储层有很好的匹配。它有四个特性。大颗粒 IO 单元就是一次读取一个 Blocklet 中的某一个 Column Chunk，Blocklet 大概有一百万行的记录；跳跃解码只会按照 page 的顺序解码，有统计值，有 min max，根据过滤条件解码，减少不必要的解码解压缩，提上 CPU 利用率；与 Spark 对接需要做向量化解码和 Spark 向量化的处理；堆外内存，大报表生成业务需要扫描大量数据，因此会产生很多 GC，所以 Carbon 内部扫描之后会使用 offheap 内存保持数据，即把解码解压过程在堆外完成，以此减少 GC。

### 延迟解码

延迟解码特性能提数据汇聚性能。比如 select c3, sum(c2) from t1 group by c3; ，假设 C3 是个字符串，要在 C3 上做 groupby，string 是一个非常低效的 aggregation，如果我们能将 C3 从 string 变为 int 就能变成非常高效。所以我们做了一个全局字典特性，如果 C3 是 string，我们需要提前做 4 点编码，将所有的 string 变成 1，2，3，4 此类字典编码，然后在优化器看到这个 plan 之后, 使用延迟解码优化策略，用 int 值去做 GroupBy，最后当这个数据做完要交给用户之前，再将 int 值转成 string 值，这样便可提升 GroupBy 整个的性能。

## 编译依赖

- thrift
- spark 2.1.0

## 构建CarbonData项目 # 也可下载官方的jar包

### 构建方法

[https://github.com/apache/carbondata/blob/master/build/README.md](https://github.com/apache/carbondata/blob/master/build/README.md)

### 源码和jar包地址

[http://carbondata.apache.org/](http://carbondata.apache.org/)

## spark2.1配置CarbonData(standalone spark集群)

### 地址：

[http://carbondata.apache.org/installation-guide.html](http://carbondata.apache.org/installation-guide.html)

### 前提条件

- hdfs和yarn必须被安装并且在运行
- spark必须被安装并且运行在所有客户端
- CarbonData用户必须有权限操纵hdfs # 忽略

### 步骤

1. 获取jar包

   从./assembly/target/scala-2.1x/carbondata_xxx.jar获取到jar包，拷贝到$SPARK_HOME/carbonlib文件夹(不存在则创建)。

2. 增加配置文件

   复制./conf/carbon.properties.template到$SPARK_HOME/conf/并重命名为carbon.properties

3. 增加carbonlib文件夹到spark classpath

   编辑 $SPARK_HOME/conf/spark-env.sh 文件并且编辑追加SPARK_CLASSPATH的值$SPARK_HOME/carbonlib/\*

4. 在所有节点重复步骤1至3

5. 在spark[master] 节点配置$SPARK_HOME/conf/spark-defaults.conf文件中配置以下属性。

  | Property | Value | Description |
  | - | - | - |
  | spark.driver.extraJavaOptions | -Dcarbon.properties.filepath=$SPARK_HOME/conf/carbon.properties | A string of extra JVM options to pass to the driver. For instance, GC settings or other logging. |
  | spark.executor.extraJavaOptions | -Dcarbon.properties.filepath=$SPARK_HOME/conf/carbon.properties | A string of extra JVM options to pass to executors. For instance, GC settings or other logging. NOTE: You can enter multiple values separated by space. |

6. 增加配置到$SPARK_HOME/conf/carbon.properties

   | 属性 | 必须 | Description | Example | Remark |
   | - | - | - |
   | carbon.storelocation | NO | Location where data CarbonData will create the store and write the data in its own format. If not specified then it takes spark.sql.warehouse.dir path | hdfs://HOSTNAME:8020/Opt/CarbonStore | Propose to set HDFS directory |

7. 验证安装

```shell
spark-shell --master spark://master:7077 --total-executor-cores 2 --executor-memory 2G
```

**注意**: 确保已拥有CarbonData jar和文件的权限，驱动程序和执行程序将通过这些权限启动。

## spark2.1配置CarbonData(spark yarn集群)

### 前提条件

- hdfs和yarn必须被安装并且在运行
- spark必须被安装并且运行在所有客户端
- CarbonData用户必须有权限操纵hdfs # 忽略

### 步骤

1. 获取jar包

   从./assembly/target/scala-2.1x/carbondata_xxx.jar获取到jar包，拷贝到$SPARK_HOME/carbonlib文件夹(不存在则创建)。

2. 增加配置文件

   复制./conf/carbon.properties.template到$SPARK_HOME/conf/并重命名为carbon.properties

3. 增加压缩文件

   给carbonlib文件夹创建tar.gz文件，并移动至carbonlib文件夹

   ```shell
   cd $SPARK_HOME
   tar -zcvf carbondata.tar.gz carbonlib/
   mv carbondata.tar.gz carbonlib/
   ```
4. 在$SPARK_HOME/conf/spark-defaults.conf文件中配置以下属性。

   | 属性 | 描述 | 值 |
   | - | - | - |
   | spark.master | 将此值设置为在yarn集群模式下运行spark.	设置yarn-client在yarn集群模式下运行Spark。 |
   | spark.yarn.dist.files | 每个执行程序放置工作目录的文件，列表以逗号分隔。 | /opt/spark/conf/carbon.properties |
   | spark.yarn.dist.archives | Comma-separated list of archives to be extracted into the working directory of each executor. | $SPARK_HOME/carbonlib/carbondata.tar.gz |
   | spark.executor.extraJavaOptions | A string of extra JVM options to pass to executors. For instance NOTE: You can enter multiple values separated by space. | -Dcarbon.properties.filepath=carbon.properties |
   | spark.executor.extraClassPath | Extra classpath entries to prepend to the classpath of executors. NOTE: If SPARK_CLASSPATH is defined in spark-env.sh, then comment it and append the values in below parameter | spark.driver.extraClassPath	carbondata.tar.gz/carbonlib/* |
   | spark.driver.extraClassPath | Extra classpath entries to prepend to the classpath of the driver. NOTE: If SPARK_CLASSPATH is defined in spark-env.sh, then comment it and append the value in below parameter spark.driver.extraClassPath. | $SPARK_HOME/carbonlib/* |
   | spark.driver.extraJavaOptions | A string of extra JVM options to pass to the driver. For instance, GC settings or other logging. | -Dcarbon.properties.filepath=$SPARK_HOME/conf/carbon.properties |

5. 在$SPARK_HOME/conf/carbon.properties中增加配置

   | 属性 | Required | Description | Example | Default Value |
   | --- | --- | --- | --- | --- |
   | carbon.storelocation | NO | CarbonData创建存储并以自己的格式编写数据的位置。如果没有指定，则需要spark.sql.warehouse.dir.path。 | hdfs://HOSTNAME:8020/Opt/CarbonStore | Propose to set HDFS directory |

6. 验证安装

   ```shell
   ./bin/spark-shell --master yarn-client --driver-memory 1g --executor-cores 2 --executor-memory 2G
   ```

## CDH spark2.X配置CarbonData(spark yarn集群)

### 前提条件

- hdfs和yarn必须被安装并且在运行
- spark必须被安装并且运行在所有客户端
- CarbonData用户必须有权限操纵hdfs # 忽略

### 步骤

1. 编译
   ```shell
   mvn -DskipTests -Pspark-2.1 -Dspark.version=2.1.0 clean package
   mvn -DskipTests -Pspark-2.2 -Dspark.version=2.2.1 clean package
   ```

2. 配置 carbon.properties

   ```shell
   ####### System Configuration ########
   #Mandatory. Carbon Store path
   carbon.storelocation=hdfs://nameservice/carbon
   #Base directory for Data files
   #carbon.ddl.base.hdfs.url=hdfs://hostname:8020/carbon/data
   #Path where the bad records are stored
   carbon.badRecords.location=/opt/test
   ######################
   ```
3. 给carbonlib文件夹创建tar.gz文件，并移动至carbonlib文件夹

   ```shell
   cd $SPARK_HOME
   tar -zcvf carbondata.tar.gz carbonlib/
   mv carbondata.tar.gz carbonlib/
   ```

4. 通过 CDH 的 webUI 配置 carbon.properties

   搜索spark-default并填入以下信息

   ```shell
   spark.master=yarn-client
   spark.yarn.dist.files=/opt/cloudera/parcels/SPARK2/meta/carbon.properties
   spark.yarn.dist.archives=/opt/cloudera/parcels/SPARK2/lib/spark2/carbonlib/carbondata.tar.gz
   spark.executor.extraJavaOptions=-Dcarbon.properties.filepath=carbon.properties
   spark.executor.extraClassPath=carbondata.tar.gz/carbonlib/*
   spark.driver.extraClassPath=/opt/cloudera/parcels/SPARK2/lib/spark2/carbonlib/*
   spark.driver.extraJavaOptions=-Dcarbon.properties.filepath=/opt/cloudera/parcels/SPARK2/meta/carbon.properties
   spark.dynamicAllocation.enabled true
   spark.shuffle.service.enabled true
   spark.dynamicAllocation.minExecutors 0
   spark.dynamicAllocation.maxExecutors 20
   ```

5. 分发文件

   ```shell
   scp carbonlib *
   scp conf/carbon.properties /opt/cloudera/parcels/SPARK2/meta/
   ```

6. 验证安装

   ```shell
   ./bin/spark-shell --master yarn-client --driver-memory 1g --executor-cores 2 --executor-memory 2G
   ```

## 测试

```shell
cd carbondata
cat > sample.csv << EOF
id,name,city,age
1,david,shenzhen,31
2,eason,shenzhen,27
3,jarry,wuhan,35
EOF
spark-shell --jars <carbondata assembly jar path>
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.CarbonSession._
val carbon = SparkSession.builder().config(sc.getConf).getOrCreateCarbonSession("hdfs://hdfs-30:9000/carbondata/store")
carbon.sql("CREATE TABLE IF NOT EXISTS test_table( id string, name string, city string, age Int) STORED BY 'carbondata'")
carbon.sql("LOAD DATA INPATH 'hdfs:///carbondata/sample.csv' INTO TABLE test_table")
carbon.sql("LOAD DATA INPATH 'hdfs:///carbondata/sample.csv' INTO TABLE test_table")
carbon.sql("select * from default.test_table").show
```

#### 常见问题

Failed to execute goal on project hive-exec: Could not resolve dependencies for project org.apache.hive:hive-exec:jar:2.3.0: Could not find artifact org.pentaho:pentaho-aggdesigner-algorithm:jar:5.1.5-jhyde in alimaven (http://maven.aliyun.com/nexus/content/groups/public/) -> [Help 1]

#### 解决办法

请手动下载Jar包pentaho-aggdesigner-algorithm-5.1.5-jhyde.jar

下载地址：
[https://public.nexus.pentaho.org/content/groups/omni/org/pentaho/pentaho-aggdesigner-algorithm/5.1.5-jhyde/](https://public.nexus.pentaho.org/content/groups/omni/org/pentaho/pentaho-aggdesigner-algorithm/5.1.5-jhyde/)
并执行

```shell
mvn install:install-file \
-DgroupId=org.pentaho \
-DartifactId=pentaho-aggdesigner-algorithm \
-Dversion=5.1.5-jhyde \
-Dpackaging=jar \
-Dfile=./pentaho-aggdesigner-algorithm-5.1.5-jhyde.jar
```

#### 常见问题

Could not find artifact org.restlet.jee:org.restlet:jar:2.3.0

#### 解决办法

到http://maven.restlet.org下载相关文件，并放到maven repo的相关目录下即可。

#### 常见问题

CarbonData 报错 ClassNotFoundException: org.apache.spark.sql.catalyst.CatalystConf 但是 spark 引入无问题

#### 解决办法

1. 只支持 spark 2.1.0 重新编译

   ```shell
   mvn clean package -Dspark.version=2.1.0 -Pspark-2.1 -DskipTests
   ```
   
2. 未解决

#### 常见问题

元数据在本地

#### 解决办法

配置hive并将hive-site.xml放入spark/conf下

#### 参考网址

[https://www.jianshu.com/p/7733da82a9ce](https://www.jianshu.com/p/7733da82a9ce)
