---
layout: post
category: 数据运维
title: "carbondata语言参考"
tag: [ hadoop ]
excerpt: CarbonData有自己的解析器，除了Spark的SQL解析器之外，还可以解析和处理与CarbonData表处理相关的某些命令。
---

## 摘要

CarbonData有自己的解析器，除了Spark的SQL解析器之外，还可以解析和处理与CarbonData表处理相关的某些命令。

## 数据类型

参考地址: [http://carbondata.apache.org/supported-data-types-in-carbondata.html](http://carbondata.apache.org/supported-data-types-in-carbondata.html)

### 数字类型

- SMALLINT
- INT/INTEGER
- BIGINT
- DOUBLE
- DECIMAL
- FLOAT
- BYTE

**注意** Float 和 Bytes 仅被支持在 SDK 和 FileFormat.

### 日期/时间类型

- TIMESTAMP
- DATE

### 字符串类型

- STRING
- CHAR
- VARCHAR

**注意** 对于 string 最长 32000 字符, use LONG_STRING_COLUMNS in table property. Please refer to TBLProperties in CreateTable for more information.

### 复杂类型

- arrays: ARRAY<data_type>
- structs: STRUCT<col_name : data_type COMMENT col_comment, ...>
- maps: MAP<primitive_type, data_type>

**注意** Only 2 level complex type schema is supported for now.

### 其他类型

- BOOLEAN

## DDL:Create,Drop,Partition,Bucketing,Alter,CTAS,External Table

参考地址: [http://carbondata.apache.org/ddl-of-carbondata.html](http://carbondata.apache.org/ddl-of-carbondata.html)

### 创建表

此命令可用于通过指定字段列表和表属性来创建CarbonData表。还可以指定表需要存储的位置。

```sql
CREATE TABLE [IF NOT EXISTS] [db_name.]table_name[(col_name data_type , ...)]
STORED AS carbondata
[TBLPROPERTIES (property_name=property_value, ...)]
[LOCATION 'path']
```

CarbonData也支持"STORED AS carbondata"和"USING carbondata". 演示代码位置[https://github.com/apache/carbondata/blob/master/examples/spark2/src/main/scala/org/apache/carbondata/examples/CarbonSessionExample.scala](https://github.com/apache/carbondata/blob/master/examples/spark2/src/main/scala/org/apache/carbondata/examples/CarbonSessionExample.scala)

### 对查询结果创建表

这个功能允许用户创建一张carbondata表从 Parquet/Hive/Carbon 表中的任何一个.

```sql
CREATE TABLE [IF NOT EXISTS] [db_name.]table_name
STORED AS carbondata
[TBLPROPERTIES (key1=val1, key2=val2, ...)]
AS select_statement;
```

### 创建外部表

此函数允许用户通过指定位置来创建外部表。

```sql
CREATE EXTERNAL TABLE [IF NOT EXISTS] [db_name.]table_name
STORED AS carbondata LOCATION '$FilesPath'
```

## 创建数据库

可以指定位置

```sql
CREATE DATABASE [IF NOT EXISTS] database_name [LOCATION path];
```

## 表管理

### 显示表

这个命令可以展示当前数据库或指定数据库的的所有表

```sql
SHOW TABLES [IN db_Name]
```

### 修改表

### 重命名表

```sql
ALTER TABLE [db_name.]table_name RENAME TO new_table_name
```

### 增加列

```sql
ALTER TABLE [db_name.]table_name ADD COLUMNS (col_name data_type,...)
TBLPROPERTIES('DICTIONARY_INCLUDE'='col_name,...',
'DEFAULT.VALUE.COLUMN_NAME'='default_value')
```

### 删除列

```sql
ALTER TABLE [db_name.]table_name DROP COLUMNS (col_name, ...)
```

### 改变数据类型

```sql
ALTER TABLE [db_name.]table_name CHANGE col_name col_name changed_column_type
```

### 合并索引

此命令用于将段中的所有CarbonData索引文件（.carbonndex）合并为单个CarbonData索引合并文件（.carbonndexmerge）。这提高了第一次查询的性能。

```sql
ALTER TABLE [db_name.]table_name COMPACT 'SEGMENT_INDEX'
```

### 设置/取消设置本地目录属性

```sql
ALTER TABLE tablename SET TBLPROPERTIES('LOCAL_DICTIONARY_ENABLE'='false','LOCAL_DICTIONARY_THRESHOLD'='1000','LOCAL_DICTIONARY_INCLUDE'='column1','LOCAL_DICTIONARY_EXCLUDE'='column2')
```

### 删除表

```sql
DROP TABLE [IF EXISTS] [db_name.]table_name
```

### 刷新表

此命令用于从现有的Carbon表数据向Hive元存储目录注册Carbon表。

```sql
REFRESH TABLE $db_NAME.$table_NAME
```

### 表和列的注释

### 创建表时

```sql
CREATE TABLE [IF NOT EXISTS] [db_name.]table_name[(col_name data_type [COMMENT col_comment], ...)]
  [COMMENT table_comment]
STORED AS carbondata
[TBLPROPERTIES (property_name=property_value, ...)]
```

示例

```sql
CREATE TABLE IF NOT EXISTS productSchema.productSalesTable (
                              productNumber Int COMMENT 'unique serial number for product')
COMMENT "This is table comment"
 STORED AS carbondata
 TBLPROPERTIES ('DICTIONARY_INCLUDE'='productNumber')
```

### 修改表时

```shell
ALTER TABLE carbon SET TBLPROPERTIES ('comment'='this table comment is modified'); # 添加注释
ALTER TABLE carbon UNSET TBLPROPERTIES ('comment'); # 删除注释
```

## 分区

### 标准分区

### 创建分区表

```sql
CREATE TABLE [IF NOT EXISTS] [db_name.]table_name
  [(col_name data_type , ...)]
  [COMMENT table_comment]
  [PARTITIONED BY (col_name data_type , ...)]
  [STORED BY file_format]
  [TBLPROPERTIES (property_name=property_value, ...)]
```

### 显示分区

```sql
SHOW PARTITIONS [db_name.]table_name
```

### 删除分区

```sql
ALTER TABLE table_name DROP [IF EXISTS] PARTITION (part_spec, ...)
```

### 插入覆盖

此命令允许您在特定分区上插入或加载覆盖。

```sql
INSERT OVERWRITE TABLE table_name
PARTITION (column = 'partition_name')
select_statement
```

### CARBONDATA分区(HASH,RANGE,LIST)

alpha功能，此分区功能不支持更新和删除数据。

此分区支持3种类型(Hash,Range,List)，类似于其他系统的分区特性，carbondata的分区特性可以通过对分区列进行过滤来提高查询性能。

### 创建HASH分区表

```sql
CREATE TABLE [IF NOT EXISTS] [db_name.]table_name
                  [(col_name data_type , ...)]
PARTITIONED BY (partition_col_name data_type)
STORED AS carbondata
[TBLPROPERTIES ('PARTITION_TYPE'='HASH',
                'NUM_PARTITIONS'='N' ...)]
```

### 创建Range分区表

```sql
CREATE TABLE [IF NOT EXISTS] [db_name.]table_name
                  [(col_name data_type , ...)]
PARTITIONED BY (partition_col_name data_type)
STORED AS carbondata
[TBLPROPERTIES ('PARTITION_TYPE'='RANGE',
                'RANGE_INFO'='2014-01-01, 2015-01-01, 2016-01-01, ...')]
```

### 创建List分区表

```sql
CREATE TABLE [IF NOT EXISTS] [db_name.]table_name
                  [(col_name data_type , ...)]
PARTITIONED BY (partition_col_name data_type)
STORED AS carbondata
[TBLPROPERTIES ('PARTITION_TYPE'='LIST',
                'LIST_INFO'='A, B, C, ...')]
```

### 显示分区

```sql
SHOW PARTITIONS [db_name.]table_name
```

### 增加新分区

```sql
SHOW PARTITIONS [db_name.]table_name
```

### 分割分区

```sql
ALTER TABLE [db_name].table_name SPLIT PARTITION(partition_id) INTO('new_partition1', 'new_partition2'...)
```

### 删除分区

删除分区保留数据

```sql
ALTER TABLE [db_name].table_name DROP PARTITION(partition_id)
```

删除分区和数据

```sql
ALTER TABLE [db_name].table_name DROP PARTITION(partition_id) WITH DATA
```

### 桶(BUCKETING)

Bucketing特性可用于将表/分区数据分发/组织到多个文件中，以便在同一个文件中存在类似的记录。创建表时，用户需要指定要用于bucketing的列和bucket的数量。对于bucket的选择，使用列的Hash值。

```sql
CREATE TABLE [IF NOT EXISTS] [db_name.]table_name
                  [(col_name data_type, ...)]
STORED AS carbondata
TBLPROPERTIES('BUCKETNUMBER'='noOfBuckets',
'BUCKETCOLUMNS'='columnname')
```

## DML: Load, Insert, Update, Delete

参考地址: [http://carbondata.apache.org/dml-of-carbondata.html](http://carbondata.apache.org/dml-of-carbondata.html)

### 加载数据

### 加载文件到carbondata表中

```sql
LOAD DATA [LOCAL] INPATH 'folder_path'
INTO TABLE [db_name.]table_name
OPTIONS(property_name=property_value, ...)
```

### 插入数据

未完待续

## scala编写carbondata（spark）程序

### 创建上下文

```scala
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.CarbonSession._
val carbon = SparkSession.builder().config(sc.getConf).getOrCreateCarbonSession("hdfs://127.0.0.1:9000/user/carbon/carbonstore")
carbon.sql("show tables")
```

### 创建数据库

```scala
carbon.sql("CREATE DATABASE dtwave_dev")
```

## 创表

```scala
carbon.sql("CREATE TABLE dtwave_dev.carbon_tablename_new (name String, PhoneNumber String) STORED BY 'carbondata'")
carbon.sql("insert into table dtwave_dev.carbon_tablename_new select * from dtwave_dev.spark_test")
carbon.sql("select * from dtwave_dev.carbon_tablename_new").show
```

## 入库

### SQL

```sql
CREATE TABLE tablename (name String, PhoneNumber String) STORED BY "carbondata"
TBLPROPERTIES (...)
LOAD DATA [LOCAL] INPATH 'folder path' [OVERWRITE] INTO TABLE tablename OPTIONS(...)
INSERT INTO TABLE tablennme select_statement1 FROM table1;
```

### DataFrame

```scala
df.write.format(“carbondata").options("tableName", "t1")) .mode(SaveMode.Overwrite).save()
```

## 查询

```scala
SELECT projectlist FROM t1 WHERE condlist GROUP BY columns ORDER BY columns
```

## 更新

### 更新一列

```scala
UPDATE table1 A
SET A.REVENUE = A.REVENUE - 10 WHERE A.PRODUCT = 'phone'
Modify two columns in table1
```

### 更新两列

```scala
UPDATE table1 A
SET (A.PRODUCT, A.REVENUE) =
(
SELECT PRODUCT, REVENUE
FROM table2 B
WHERE B.CITY = A.CITY AND B.BROKER = A.BROKER
)
WHERE A.DATE BETWEEN '2017-01-01' AND '2017-01-31'
```

## 删除

```scala
DELETE FROM table1 A WHERE A.CUSTOMERID = ‘123’
carbon.sql("select * from dtwave_dev.carbon_tablename_new").show
carbon.sql("delete from dtwave_dev.carbon_tablename_new a WHERE a.name='1'")
carbon.sql("select * from dtwave_dev.carbon_tablename_new").show
carbon.sql("update dtwave_dev.carbon_tablename_new A SET (A.name) = A.name WHERE A.PhoneNumber = '4'")
carbon.sql("UPDATE dtwave_dev.carbon_tablename_new a SET (a.name, a.PhoneNumber) = ( SELECT '5' as name ,'6' from dtwave_dev.carbon_tablename_new b)")
carbon.sql("UPDATE dtwave_dev.carbon_tablename_new a SET (a.name, a.PhoneNumber) = ( SELECT '5' as name ,'6' as PhoneNumber)")
```

## HDFS对应的文件

### HDFS 目录

```shell
/user/carbon/carbonstore/dtwave_dev/carbon_tablename_new
drwxr-xr-x  hulb  supergroup  0 B 0   0 B Fact
drwxr-xr-x  hulb  supergroup  0 B 0   0 B Metadata
```

### 数据文件

```shell
/user/carbon/carbonstore/dtwave_dev/carbon_tablename_new/Fact/Part0
Permission  Owner   Group   Size  Replication Block Size  Name
drwxr-xr-x  hulb  supergroup  0 B 0   0 B Segment_0
drwxr-xr-x  hulb  supergroup  0 B 0   0 B Segment_1
```

### 元数据文件

```shell
/user/carbon/carbonstore/dtwave_dev/carbon_tablename_new/Metadata

Permission  Owner   Group   Size  Replication Block Size  Name
-rw-r--r--  hulb  supergroup  16 B  2   128 MB  62acf472-3574-434e-a53f-f45901dff949.dict
-rw-r--r--  hulb  supergroup  11 B  2   128 MB  62acf472-3574-434e-a53f-f45901dff949.dictmeta
-rw-r--r--  hulb  supergroup  11 B  2   128 MB  62acf472-3574-434e-a53f-f45901dff949_16.sortindex
-rw-r--r--  hulb  supergroup  16 B  2   128 MB  c5c7949a-a437-41d1-8f47-a7a81e68c4ba.dict
-rw-r--r--  hulb  supergroup  11 B  2   128 MB  c5c7949a-a437-41d1-8f47-a7a81e68c4ba.dictmeta
-rw-r--r--  hulb  supergroup  11 B  2   128 MB  c5c7949a-a437-41d1-8f47-a7a81e68c4ba_16.sortindex
-rw-r--r--  hulb  supergroup  387 B   2   128 MB  schema
-rw-r--r--  hulb  supergroup  7.37 KB 2   128 MB  tablestatus
-rw-r--r--  hulb  supergroup  243 B   2   128 MB  tableupdatestatus-1505890299461
```

## java编写carbondata（spark）程序

### maven

pom.xml配置

```xml
<dependencies>
  <dependency>
    <groupId>org.apache.spark</groupId>
    <artifactId>spark-core_2.11</artifactId>
    <version>2.1.0</version>
  </dependency>
  <dependency>
    <groupId>org.apache.hadoop</groupId>
    <artifactId>hadoop-client</artifactId>
    <version>2.7.3</version>
  </dependency>
  <dependency>
    <groupId>org.apache.spark</groupId>
    <artifactId>spark-sql_2.11</artifactId>
    <version>2.1.0</version>
  </dependency>
  <dependency>
    <groupId>org.apache.spark</groupId>
    <artifactId>spark-hive_2.10</artifactId>
    <version>2.1.0</version>
  </dependency>
  <dependency>
    <groupId>org.apache.carbondata</groupId>
    <artifactId>carbondata-spark2</artifactId>
    <version>1.4.1</version>
  </dependency>
  <dependency>
    <groupId>org.apache.carbondata</groupId>
    <artifactId>carbondata-hive</artifactId>
    <version>1.4.1</version>
  </dependency>
</dependencies>
```

### CarbonDataSql.java

```java
import org.apache.spark.SparkConf;
import org.apache.spark.SparkContext;
import org.apache.spark.sql.CarbonSession;
import org.apache.spark.sql.SparkSession;
import org.apache.spark.sql.SparkSession.*;
import org.apache.spark.sql.SparkSession.Builder;

public class CarbonDataDemo {
  public static void main(String[] args) {
    SparkConf conf = (new SparkConf()).setAppName("JAVA CarbonData Demo").setMaster("spark://192.168.1.1:7077");
    SparkContext sc = new SparkContext(conf);
    Builder builder = SparkSession.builder().config(sc.getConf());
    SparkSession carbon = CarbonSession.CarbonBuilder(builder).getOrCreateCarbonSession("hdfs://192.168.20.30:9000/carbondata/store");
    carbon.sql("LOAD DATA INPATH 'hdfs://192.168.1.1:9000/carbondata/sample.csv' INTO TABLE test_table");
    carbon.sql("select * from default.test_table").show();
  }
}
```

## shell 编写carbondata（spark）程序

```shell
#!/bin/bash

exec spark2-shell --name spark-sql-test <<!EOF
import org.apache.spark.sql.SparkSession
import org.apache.spark.sql.CarbonSession._
val carbon = SparkSession.builder().config(sc.getConf).getOrCreateCarbonSession()
carbon.sql("show tables")
!EOF
```

#### 参考文档网址

[https://www.iteblog.com/archives/2078.html](https://www.iteblog.com/archives/2078.html)

[http://carbondata.apache.org/documentation.html](http://carbondata.apache.org/documentation.html)

[https://www.iteblog.com/archives/1992.html](https://www.iteblog.com/archives/1992.html)
