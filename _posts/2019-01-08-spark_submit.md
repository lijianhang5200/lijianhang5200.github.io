---
layout: post
category: 数据开发
title: "spark-submit 提交任务及参数说明"
tag: [spark]
excerpt: spark-submit 可以提交任务到 spark 集群执行，也可以提交到 hadoop 的 yarn 集群执行。
---

## 摘要

spark-submit 可以提交任务到 spark 集群执行，也可以提交到 hadoop 的 yarn 集群执行。

## 命令事例

### standalone 模式

```shell
./bin/spark-submit \
--master spark://localhost:7077 \
examples/src/main/python/pi.py
```

### 提交到 yarn

```shell
./bin/spark-submit --class org.apache.spark.examples.SparkPi \
--master yarn \
--deploy-mode cluster \
--driver-memory 1g \
--executor-memory 1g \
--executor-cores 1 \
--queue thequeue \
examples/target/scala-2.11/jars/spark-examples*.jar 10
```

## 参数说明

| 参数名 | 默认值 | 参数说明 |
| ---: | :--- | :--- |
| &#45;&#45;master | | master 的地址，提交任务到哪里执行，例如 spark://host:port,  yarn,  local |
| &#45;&#45;name |  | 应用程序的名称 |
| &#45;&#45;packages |  |  包含在driver 和executor 的 classpath 中的 jar 的 maven 坐标 |
| &#45;&#45;repositories |  | 远程 repository |
| &#45;&#45;exclude-packages |  | 为了避免冲突 而指定不包含的 package |
| &#45;&#45;queue | | 指定了放在哪个队列里执行 |
| &#45;&#45;deploy-mode |  | 在本地 (client) 启动 driver 或在 cluster 上启动，默认是 client |
| &#45;&#45;properties-file | conf/spark-defaults.conf | 加载的配置文件 |
| &#45;&#45;total-executor-cores |  | 所有 executor 总共的核数。仅仅在 mesos 或者 standalone 下使用 |
| &#45;&#45;executor-core | 1 | 每个 executor 的核数。在yarn或者standalone下使用 |
| &#45;&#45;num-executors | 2 | 启动的 executor 数量。在 yarn 下使用 |
| &#45;&#45;executor-memory | 1G | 每个 executor 的内存 |
| &#45;&#45;driver-cores | 1 | Driver 的核数。在 yarn 或者 standalone 下使用 |
| &#45;&#45;driver-memory | 1G | Driver内存 |
| &#45;&#45;driver-java-options |  | 传给 driver 的额外的 Java 选项 |
| &#45;&#45;driver-library-path |  | 传给 driver 的额外的库路径 |
| &#45;&#45;driver-class-path |  | 传给 driver 的额外的类路径 |
| &#45;&#45;conf PROP=VALUE |  | 指定 spark 配置属性的值，例如 -conf spark.executor.extraJavaOptions="-XX:MaxPermSize=256m" |
| &#45;&#45;supervise |  | Driver失败时，重启driver。在mesos或者standalone下使用 |
| &#45;&#45;proxy-user |  | 模拟提交应用程序的用户 |
| &#45;&#45;verbose |  | 打印debug信息 |
| &#45;&#45;files |  | 逗号分隔的文件，这些文件放在每个executor的工作目录下面 |
| &#45;&#45;py-files |  | 逗号分隔的”.zip”,”.egg”或者“.py”文件，这些文件放在python app的PYTHONPATH下面 |
| &#45;&#45;jars |  | 用逗号分隔的本地 jar 包，设置后，这些 jar 将包含在 driver 和 executor 的 classpath 下 |
| &#45;&#45;class |  | 应用程序的主类，仅针对 java 或 scala 应用 |
