---
layout: post
category: 数据运维
title:  "trafodion的安装与使用"
tag: [ trafodion ]
excerpt: 一条query语句可以支持多达64个join。
---

## trafodion简介：

一条query语句可以支持多达64个join

## 主要特性包括

1. 完整的ANSI SQL 92/99语言支持
2. 完整的ACID事务支持。对于读、写查询，Trafodion支持跨行，跨表和跨语句的事务保护
3. 支持多种异构存储引擎的直接访问
4. 为应用程序提供极佳的高可用性保证
5. 采用了查询间(intra-query)并发执行模式。轻松支持大数据应用
6. 同时应用编译时和运行时优化技术，优化了OLTP工作负载的性能

## 事务管理特性包括

1. 事务串行化基于开源项目HBase-Trx的实现原理，采用多版本并发控制(MVCC)
2. 增强的故障恢复机制保证了数据库中用户数据的一致性
3. 事务管理器支持多线程的SQL客户端应用
4. 支持非事务型数据访问，即直接访问底层HBase表

## 安装步骤

### 1. 安装CDH

[链接地址](pages/posts/2018/04/13/CDH安装.html)

### 2. 下载

[http://trafodion.apache.org/download.html](http://trafodion.apache.org/download.html)

### 3. trafodion安装

收集信息

```shell
tar -xzf apache-trafodion_pyinstaller*
vim python-installer/configs/db_config_default.ini
cd python-installer ;./db_install.py
```

### 4. 安装失败

```shell
kill -9 $(ps -u trafodion -o pid=)
echo NODE_LIST=\"cdh-master cdh-slave1 cdh-slave3\" >> /etc/trafodion/trafodion_config
./db_uninstall.py
rm -rf /opt/soft/trafodion-installer/*
disable 'TRAFODION._DTM_.TDDL'
disable 'TRAFODION._DTM_.TLOG0_CONTROL_POINT'
disable 'TRAFODION._DTM_.TLOG0_LOG_0'
disable 'TRAFODION._DTM_.TLOG0_LOG_1'
disable 'TRAFODION._DTM_.TLOG0_LOG_2'
disable 'TRAFODION._DTM_.TLOG0_LOG_3'
disable 'TRAFODION._DTM_.TLOG0_LOG_4'
disable 'TRAFODION._DTM_.TLOG0_LOG_5'
disable 'TRAFODION._DTM_.TLOG0_LOG_6'
disable 'TRAFODION._DTM_.TLOG0_LOG_7'
disable 'TRAFODION._DTM_.TLOG0_LOG_8'
disable 'TRAFODION._DTM_.TLOG0_LOG_9'
disable 'TRAFODION._DTM_.TLOG0_LOG_a'
disable 'TRAFODION._DTM_.TLOG0_LOG_b'
disable 'TRAFODION._DTM_.TLOG0_LOG_c'
disable 'TRAFODION._DTM_.TLOG0_LOG_d'
disable 'TRAFODION._DTM_.TLOG0_LOG_e'
disable 'TRAFODION._DTM_.TLOG0_LOG_f'
disable 'TRAFODION._MD_.AUTHS'
disable 'TRAFODION._MD_.COLUMNS'
disable 'TRAFODION._MD_.DEFAULTS'
disable 'TRAFODION._MD_.INDEXES'
disable 'TRAFODION._MD_.KEYS'
disable 'TRAFODION._MD_.LIBRARIES'
disable 'TRAFODION._MD_.LIBRARIES_USAGE'
disable 'TRAFODION._MD_.OBJECTS'
disable 'TRAFODION._MD_.OBJECTS_UNIQ_IDX'
disable 'TRAFODION._MD_.REF_CONSTRAINTS'
disable 'TRAFODION._MD_.ROUTINES'
disable 'TRAFODION._MD_.SEQ_GEN'
disable 'TRAFODION._MD_.TABLES'
disable 'TRAFODION._MD_.TABLE_CONSTRAINTS'
disable 'TRAFODION._MD_.TABLE_CONSTRAINTS_IDX'
disable 'TRAFODION._MD_.TEXT'
disable 'TRAFODION._MD_.UNIQUE_REF_CONSTR_USAGE'
disable 'TRAFODION._MD_.VERSIONS'
disable 'TRAFODION._MD_.VIEWS'
disable 'TRAFODION._MD_.VIEWS_USAGE'
disable 'TRAFODION._REPOS_.METRIC_QUERY_AGGR_TABLE'
disable 'TRAFODION._REPOS_.METRIC_QUERY_TABLE'
disable 'TRAFODION._REPOS_.METRIC_SESSION_TABLE'
disable 'TRAFODION._REPOS_.METRIC_TEXT_TABLE'
drop 'TRAFODION._DTM_.TDDL'
drop 'TRAFODION._DTM_.TLOG0_CONTROL_POINT'
drop 'TRAFODION._DTM_.TLOG0_LOG_0'
drop 'TRAFODION._DTM_.TLOG0_LOG_1'
drop 'TRAFODION._DTM_.TLOG0_LOG_2'
drop 'TRAFODION._DTM_.TLOG0_LOG_3'
drop 'TRAFODION._DTM_.TLOG0_LOG_4'
drop 'TRAFODION._DTM_.TLOG0_LOG_5'
drop 'TRAFODION._DTM_.TLOG0_LOG_6'
drop 'TRAFODION._DTM_.TLOG0_LOG_7'
drop 'TRAFODION._DTM_.TLOG0_LOG_8'
drop 'TRAFODION._DTM_.TLOG0_LOG_9'
drop 'TRAFODION._DTM_.TLOG0_LOG_a'
drop 'TRAFODION._DTM_.TLOG0_LOG_b'
drop 'TRAFODION._DTM_.TLOG0_LOG_c'
drop 'TRAFODION._DTM_.TLOG0_LOG_d'
drop 'TRAFODION._DTM_.TLOG0_LOG_e'
drop 'TRAFODION._DTM_.TLOG0_LOG_f'
drop 'TRAFODION._MD_.AUTHS'
drop 'TRAFODION._MD_.COLUMNS'
drop 'TRAFODION._MD_.DEFAULTS'
drop 'TRAFODION._MD_.INDEXES'
drop 'TRAFODION._MD_.KEYS'
drop 'TRAFODION._MD_.LIBRARIES'
drop 'TRAFODION._MD_.LIBRARIES_USAGE'
drop 'TRAFODION._MD_.OBJECTS'
drop 'TRAFODION._MD_.OBJECTS_UNIQ_IDX'
drop 'TRAFODION._MD_.REF_CONSTRAINTS'
drop 'TRAFODION._MD_.ROUTINES'
drop 'TRAFODION._MD_.SEQ_GEN'
drop 'TRAFODION._MD_.TABLES'
drop 'TRAFODION._MD_.TABLE_CONSTRAINTS'
drop 'TRAFODION._MD_.TABLE_CONSTRAINTS_IDX'
drop 'TRAFODION._MD_.TEXT'
drop 'TRAFODION._MD_.UNIQUE_REF_CONSTR_USAGE'
drop 'TRAFODION._MD_.VERSIONS'
drop 'TRAFODION._MD_.VIEWS'
drop 'TRAFODION._MD_.VIEWS_USAGE'
drop 'TRAFODION._REPOS_.METRIC_QUERY_AGGR_TABLE'
drop 'TRAFODION._REPOS_.METRIC_QUERY_TABLE'
drop 'TRAFODION._REPOS_.METRIC_SESSION_TABLE'
drop 'TRAFODION._REPOS_.METRIC_TEXT_TABLE'
```

## 语法

### 权限相关命令

1. 查看系统有哪些用户

   ```shell
   get users;
   ```

2. 查看系统有哪些角色

   ```shell
   get roles;
   ```

3. 查看某个用户属于哪个角色

   ```shell
   get roles for user user_name;
   ```

4. 查看某个角色有哪些用户

   ```shell
   get users for role role_name；
   ```

5. 查看某个用户有哪些权限

   ```shell
   get privileges for user user_name
   ```

6. 查看某个角色有哪些权限

   ```shell
   get privileges for role role_name
   ```

7. 查看系统有哪些全局权限

   ```shell
   get component privileges on sql_operations
   ```

8. 查看某个用户有哪些全局权限

   ```shell
   get component privileges on sql_operations for user_name
   ```

9. 表和字段的注释功能

   ```shell
   comment on table table_name is 'comment of table';
   comment on column table_name.field is 'comment of field';
   ```

### DDL语句

1. 建表

   ```shell
   create table table_name(field1 int not null [GENERATE BY DEFAULT AS IDENTITY ([START WITH integer,...])], field2 varchar(10),primary key (field1));
   ```

2. sequence与自增序列

   ```shell
   # 创建
   CREATE SEQUENCE [[catalog-name.]schema-name.]sequence_name
   [START WITH integer]
   [INCREMENT BY integer]
   [MAXVALUE integer | NOMAXVALUE]
   [MINVALUE integer]
   [CACHE integer | NO CACHE]
   [CYCLE | NO CYCLE]
   [DATA TYPE]
   # 添加自增序列
   GENERATE BY DEFAULT AS IDENTITY
   GENERATE ALWAYS AS IDENTTIY # 不能手动插入值
   # 使用序列
   CREATE TABLE t1 (id LARGEINT GENERATED BY DEFAULT AS IDENTITY (START WITH 1  INCREMENT BY 1  MAXVALUE 9223372036854775806  MINVALUE 1 CACHE 25  NO CYCLE  LARGEINT  ) NOT NULL NOT DROPPABLE SERIALIZED ,f1 VARCHAR(55) NOT NULL,f2 VARCHAR(55) NOT NULL,f3 VARCHAR(55) NOT NULL,f4 VARCHAR(55) NOT NULL,f5 VARCHAR(55) NOT NULL,f6 VARCHAR(55) NOT NULL,f7 VARCHAR(55) NOT NULL,f8 VARCHAR(55) NOT NULL,f9 VARCHAR(55) NOT NULL,f10 VARCHAR(55) NOT NULL,f11 VARCHAR(55) NOT NULL,f12 VARCHAR(55) NOT NULL,f13 VARCHAR(55) NOT NULL,f14 VARCHAR(55) NOT NULL,f15 VARCHAR(55) NOT NULL,f16 VARCHAR(55) NOT NULL, f17 VARCHAR(55) NOT NULL, f18 varchar(20) NOT NULL,f19 INTEGER NOT NULL,f20 INTEGER NOT NULL)
   CREATE TABLE t1 (id LARGEINT GENERATED BY DEFAULT AS IDENTITY (START WITH 1  INCREMENT BY 1  MAXVALUE 9223372036854775806  MINVALUE 1 CACHE 25  NO CYCLE  LARGEINT  ) NOT NULL NOT DROPPABLE SERIALIZED ,f1 VARCHAR(55) NOT NULL,f2 VARCHAR(55) NOT NULL,f3 VARCHAR(55) NOT NULL,f4 VARCHAR(55) NOT NULL,f5 VARCHAR(55) NOT NULL,f6 VARCHAR(55) NOT NULL,f7 VARCHAR(55) NOT NULL,f8 VARCHAR(55) NOT NULL,f9 VARCHAR(55) NOT NULL,f10 VARCHAR(55) NOT NULL,f11 VARCHAR(55) NOT NULL,f12 VARCHAR(55) NOT NULL,f13 VARCHAR(55) NOT NULL,f14 VARCHAR(55) NOT NULL,f15 VARCHAR(55) NOT NULL,f16 VARCHAR(55) NOT NULL, f17 VARCHAR(55) NOT NULL, f18 varchar(20) NOT NULL,f19 INTEGER NOT NULL,f20 INTEGER NOT NULL)
   ```

3. CREATE TABLE TRAFODION.SEABASE.TEST1 (AA LARGEINT GENERATED BY DEFAULT AS IDENTITY (START WITH 1  INCREMENT BY 1  MAXVALUE 9223372036854775806  MINVALUE 1 CACHE 25  NO CYCLE  LARGEINT  ) NOT NULL NOT DROPPABLE SERIALIZED , BB VARCHAR(10) CHARACTER SET ISO88591 COLLATE DEFAULT DEFAULT NULL SERIALIZED );

   1. 建索引
   2. 建视图
   3. 查看建表语句

      showddl table_name;

   4. 临时表：指定一个可变表，该表仅存在于创建表会话期间。会话结束时，该表自动删除。

      CREATE VOLATILE TABLE ...

   5. 查看hbase原生表

      get \[ USER | SYSTEM | EXTERNAL | ALL ]  hbase objects;

   6. 查看hive中的表

      get tables in schema hive.hive;

4. 数据加载

   Trickle Load（持续加载）：数据量较小 立即插入
        INSERT
        UPSERT
        UPSERT USING LOAD
   Bulk Load（批量加载）	：数据量较大 阶段性数据并且是批量加载的方式
        LOAD

5. 导出数据

   ```shell
   UNLOAD [WITH [option]...] INTO 'targe-location' SELECT ...FROM source-table ...
   option
       DELIMITER { ‘delimitor-string’ | delimiter-ascii-value}
       RECORD_SEPARATOR {‘separator-literal’ | separator-ascii-value}
       NULL_STRING ‘string-literal’
       PURGEDATA FROM TARGET
       COMPRESSION GZIP
       MERGE FILE merged_file_path \[OVERWRITE]
       NO OUTPUT
       {NEW | EXISTING} SNAPSHOT HAVING SUFFIX ‘string’
   target-location
       抽取数据被写入的HDFS目标文件夹的路径，执行UNLOAD用户需要对文件夹有写入权限，若是并行运行UNLOAD，则目标文件夹将产生多个文件。
   DELIMITER { ‘delimitor-string’ | delimiter-ascii-value}
       指定列分隔符，默认为”|”，分隔符也可以是一个ASCII值
   RECORD_SEPARATOR {‘separator-literal’ | separator-ascii-value}
       指定行间分隔符，默认为换行符”\n”，分隔符也可以是ASCII值
   NULL_STRING ‘string-literal’
       指定一个用于表示空值的字符串，默认为空字符串
   PURGEDATA FROM TARGET
       导出前将目标HDFS文件夹清空
   COMPRESSION GZIP
       导出数据使用GZIP压缩并写入磁盘
   MERGE FILE merged_file_path \[OVERWRITE]
       将导出的数据合并到指定的路径下面的一个文件中
   NO OUTPUT
       不打印UNLODAD过程中的状态消息，默认打印
   {NEW | EXISTING} SNAPSHOT HAVING SUFFIX ‘string’
       导出数据期间发起HBase快照扫描，扫描期间，Bulk Unloader从查询计划中获得一份Trafodion表清单，然后将为这些表创建和验证快照
   ```

## odb 工具

### 安装

```shell
tar -xzf TRAF_ODBC_Linux_Driver_64.tar.gz
cd PkgTmp/
./install.sh
```

### 使用

```shell
odb64luo –u user –p xx –d dsn –l src=customer.tbl:tgt=TRAFODION.MAURIZIO.CUSTOMER \
:fs=\|:rows=1000:loadcmd=UL:truncate:parallel=4
options
  Loads the file named customer.tbl (src=customer.tbl)
  in the table TRAFODION.MAURIZIO.CUSTOMER (tgt=TRAFODION.MAURIZIO.CUSTOMER)
  using | (vertical bar) as a field separator (fs=\|)
  using 1000 rows as row-set buffer (rows=1000)
  using UPSERT USING LOAD syntax to achieve better throughput as described in Trafodion Load and Transform Guide
  truncating the target table before loading (truncate)
  using 4 parallel threads to load the target table (parallel=4)
```

### 具体选项点击

[http://trafodion.apache.org/docs/2.1.0/odb/index.html#_load_extract_copy](http://trafodion.apache.org/docs/2.1.0/odb/index.html#_load_extract_copy)

## 修改数据库为hive

#### 参考地址:

[https://cwiki.apache.org/confluence/pages/viewpage.action?pageId=65148054](https://cwiki.apache.org/confluence/pages/viewpage.action?pageId=65148054) 最下面
