---
layout: post
category: 数据运维
title: "ElasticSearch的安装与使用"
tag: [ hadoop ]
excerpt: 一个基于Lucene的搜索服务器。
---

## 介绍

ElasticSearch是一个基于Lucene的搜索服务器。它提供了一个分布式多用户能力的全文搜索引擎，基于RESTful web接口。Elasticsearch是用Java开发的，并作为Apache许可条款下的开放源码发布，是当前流行的企业级搜索引擎。设计用于云计算中，能够达到实时搜索，稳定，可靠，快速，安装使用方便。

ElasticSearch是一个非常好用的实时分布式搜索和分析引擎，可以帮助我们快速的处理大规模数据，也可以用于全文检索，结构化搜索以及分析等。

## 安装

### 主机

- 192.168.0.10
- 192.168.0.20
- 192.168.0.30

### [安装JDK](pages/posts/2018/09/04/jdk环境配置.html)

### 安装ES

### 创建ES用户和组

```shell
groupadd elsearch
useradd elsearch -g elsearch
chown -R elsearch:elsearch elasticsearch-5.6.3
```

### vi /etc/hosts

### 创建数据和日志文件

```shell
mkdir /data/ElasticSearch
chown -R elsearch:elsearch /data/ElasticSearch
su - elsearch
mkdir -p /data/ElasticSearch/data
mkdir -p /data/ElasticSearch/logs
```

### vim /opt/ElasticSearch/config/elasticsearch.yml

```shell
cluster.name:JSJ-ES
node.name:JSJ-ES01
path.data=/data/ElasticSearch/data
path.logs=/data/ElasticSearch/logs
bootstrap.memory_lock:false
bootstrap.system_call_filter:false
network.host:192.168.0.10
http.port:9200
```

### vim /opt/ElasticSearch/config/jvm.options

### 启动

```shell
./elasticsearch # 启动es -d 后台启动
```

### 查看服务是否正常启动

```shell
ps -ef | grep ela 
```

### 安装elasticsearch-head # 一个界面化的集群操作和管理工具，可以对集群进行傻瓜式操作。

[https://github.com/mobz/elasticsearch-head](https://github.com/mobz/elasticsearch-head)

### 安装分词插件

[https://github.com/medcl/elasticsearch-analysis-ik](https://github.com/medcl/elasticsearch-analysis-ik)

## 命令

### curl

- 创建索引

  ```shell
  curl -XPUT "http://localhost:9200/music/"
  ```

- 插入文档

  ```shell
  curl -H "Content-Type: application/json"  -XPUT "http://localhost:9200/music/songs/1" -d '{ "name": "Deck the Halls", "year": 1885, "lyrics": "Fa la la la la" }'
  ```

- 查看文档

  ```shell
  curl -XGET "http://localhost:9200/music/songs/1"
  ```

- 更新文档

  ```shell
  curl -H "Content-Type: application/json" -XPUT "http://localhost:9200/music/songs/1" -d  '{"name":"Deck the Halls","year":  1886,"lyrics":"Fa la la la la" }'
  ```

- 删除文档

  ```shell
  curl -XDELETE "http://localhost:9200/music/songs/1"
  ```

- 查看索引

  ```shell
  curl -X GET 'http://localhost:9200/_cat/indices?v'
  ```

- 其他

  ```shell
  curl -X POST "http://localhost:9200/music/_open" # 打开索引   关闭索引 （_close）
  curl -X GET 'http://localhost:9200/_cat/indices?v' # 查看索引
  curl 'localhost:9200/_mapping?pretty=true' # 列出每个 Index 所包含的 Type
  curl 'localhost:9200/accounts/person/_search' # 查看某个索引下全部记录
  ```

#### 常见问题

max file descriptors [4096] for elasticsearch process is too low, increase to at least [65536]

#### 解决方案

```shell
vim /etc/security/limits.conf 
  * soft nofile 65536
  * hard nofile 131072
  * soft nproc 2048
  * hard nproc 4096
```

#### 常见问题

max virtual memory areas vm.max_map_count [65530] is too low, increase to at least [262144]

#### 解决方案

```shell
echo  vm.max_map_count=655360 >> sysctl.conf ; sysctl -p
```

#### 参考网址

[https://www.cnblogs.com/wangiqngpei557/p/5967377.html](https://www.cnblogs.com/wangiqngpei557/p/5967377.html)
