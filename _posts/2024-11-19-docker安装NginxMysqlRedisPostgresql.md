---
layout: post
category: 运维
title: "docker安装nginx/mysql/redis/postgresql"
tag: [ docker ]
excerpt: docker安装nginx/mysql/redis/postgresql。
---

## nginx

(参考网址)[https://blog.csdn.net/breakaway_01/article/details/141299349]

```shell
docker run --name nginx -p 80:80 -d nginx:1.25.3
mkdir -p /opt/data/file/nginx
docker cp nginx:/etc/nginx/ /opt/data/file/nginx
docker cp nginx:/usr/share/nginx/html /opt/data/file/nginx
docker rm -f nginx
docker run \
  --name nginx \
  -p 80:80 \
  --restart=always \
  -v /opt/data/file/nginx/nginx/nginx.conf:/etc/nginx/nginx.conf \
  -v /opt/data/file/nginx/nginx/conf.d:/etc/nginx/conf.d \
  -v /opt/data/file/nginx/logs:/var/log/nginx \
  -v /opt/data/file/nginx/html:/usr/share/nginx/html \
  -v /opt/data/file/nginx/admin-top:/usr/share/nginx/admin-top \
  -d nginx:1.25.3
```

## mysql

(参考网址)[https://blog.csdn.net/breakaway_01/article/details/141299349]

```shell
docker run -d \
  --name mysql \
  -p 3306:3306 \
  --restart=always \
  -e TZ=Asia/Shanghai \
  -e MYSQL_ROOT_PASSWORD=root \
  -v /opt/data/mysql/data:/var/lib/mysql \
  -v /opt/data/mysql/conf:/etc/mysql/conf.d \
  -v /opt/data/mysql/init:/docker-entrypoint-initdb.d \
  mysql:8.0
```

## redis

(参考网址)[https://blog.csdn.net/qq_40104261/article/details/120738742]

```shell
mkdir -p /opt/data/file/redis/conf
cd /opt/data/file/redis/conf
cat > redis.conf <<- EOF
# Redis configuration file example.
################################## INCLUDES ###################################
# include /path/to/local.conf
# include /path/to/other.conf
################################## MODULES #####################################
# loadmodule /path/to/my_module.so
# loadmodule /path/to/other_module.so
################################## NETWORK #####################################
# bind 192.168.1.100 10.0.0.1
# bind 127.0.0.1 ::1
#bind 127.0.0.1
protected-mode no
port 6379
tcp-backlog 511
# unixsocket /tmp/redis.sock
# unixsocketperm 700
timeout 0
tcp-keepalive 300
################################# GENERAL #####################################
daemonize no
supervised no
pidfile /var/run/redis_6379.pid
loglevel notice
logfile ""
databases 16
always-show-logo yes
################################ SNAPSHOTTING  ################################
#   save ""
save 900 1
save 300 10
save 60 10000
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes
dbfilename dump.rdb
dir ./
################################# REPLICATION #################################
# replicaof <masterip> <masterport>
# masterauth <master-password>
replica-serve-stale-data yes
replica-read-only yes
repl-diskless-sync no
repl-diskless-sync-delay 5
# repl-ping-replica-period 10
# repl-timeout 60
repl-disable-tcp-nodelay no
# repl-backlog-size 1mb
# repl-backlog-ttl 3600
replica-priority 100
# min-replicas-to-write 3
# min-replicas-max-lag 10
# replica-announce-ip 5.5.5.5
# replica-announce-port 1234
################################## SECURITY ###################################
requirepass 123456
# rename-command CONFIG b840fc02d524045429941cc15f59e41cb7be6c52
# rename-command CONFIG ""
################################### CLIENTS ####################################
# maxclients 10000
############################## MEMORY MANAGEMENT ################################
# maxmemory <bytes>
# maxmemory-policy noeviction
# maxmemory-samples 5
# replica-ignore-maxmemory yes
############################# LAZY FREEING ####################################
lazyfree-lazy-eviction no
lazyfree-lazy-expire no
lazyfree-lazy-server-del no
replica-lazy-flush no
############################## APPEND ONLY MODE ###############################
appendonly yes
appendfilename "appendonly.aof"
# appendfsync always
appendfsync everysec
# appendfsync no
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-load-truncated yes
aof-use-rdb-preamble yes
################################ LUA SCRIPTING  ###############################
lua-time-limit 5000
################################ REDIS CLUSTER  ###############################
# cluster-enabled yes
# cluster-config-file nodes-6379.conf
# cluster-node-timeout 15000
# cluster-replica-validity-factor 10
# cluster-migration-barrier 1
# cluster-require-full-coverage yes
# cluster-replica-no-failover no
########################## CLUSTER DOCKER/NAT support  ########################
# cluster-announce-ip 10.1.1.5
# cluster-announce-port 6379
# cluster-announce-bus-port 6380
################################## SLOW LOG ###################################
slowlog-max-len 128
################################ LATENCY MONITOR ##############################
latency-monitor-threshold 0
############################# EVENT NOTIFICATION ##############################
notify-keyspace-events ""
############################### ADVANCED CONFIG ###############################
hash-max-ziplist-entries 512
hash-max-ziplist-value 64
list-max-ziplist-size -2
list-compress-depth 0
set-max-intset-entries 512
zset-max-ziplist-entries 128
zset-max-ziplist-value 64
hll-sparse-max-bytes 3000
stream-node-max-bytes 4096
stream-node-max-entries 100
activerehashing yes
client-output-buffer-limit normal 0 0 0
client-output-buffer-limit replica 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60
# client-query-buffer-limit 1gb
# proto-max-bulk-len 512mb
hz 10
dynamic-hz yes
aof-rewrite-incremental-fsync yes
rdb-save-incremental-fsync yes
# lfu-log-factor 10
# lfu-decay-time 1

########################### ACTIVE DEFRAGMENTATION #######################

# activedefrag yes
# active-defrag-ignore-bytes 100mb
# active-defrag-threshold-lower 10
# active-defrag-threshold-upper 100
# active-defrag-cycle-min 5
# active-defrag-cycle-max 75
# active-defrag-max-scan-fields 1000

EOF

docker run \
  --name redis \
  -p 6379:6379 \
  --restart=always \
  -v /opt/data/file/redis/conf/redis.conf:/etc/redis/redis.conf \
  -v /opt/data/file/redis/data:/data \
  -d redis:5.0 \
  redis-server /etc/redis/redis.conf --appendonly yes
```

## postgresql

(参考网址)[https://zhuanlan.zhihu.com/p/606079311]

```shell
docker run \
  --name postgres \
  -e POSTGRES_PASSWORD=123456 \
  --restart=always \
  -v /opt/data/postgres/data:/var/lib/postgresql/data \
  -d postgres:15.8
```

## xxl-job-admin

(参考网址)[https://blog.csdn.net/zhaoxichen_10/article/details/118446721]

```shell
mkdir -p /opt/data/file/xxl-job/admin/logs
docker run \
  --name xxl-job-admin \
  -p 18080:8080 \
  --restart=always \
  --link mysql \
  -e PARAMS="\
  --spring.datasource.url=jdbc:mysql://mysql:3306/xxl_job?Unicode=true&serverTimezone=Asia/Shanghai&characterEncoding=utf8&useUnicode=true&useSSL=false \
  --spring.datasource.username=root \
  --spring.datasource.password=root \
  --xxl.job.accessToken=123456" \
  -v /opt/data/file/xxl-job/admin/logs:/data/applogs \
  --privileged=true \
  -d xuxueli/xxl-job-admin:2.4.1
```

**页面访问**

打开浏览器，输入http://[宿主机的ip]:8080/xxl-job-admin
默认用户名及密码：admin/123456

## adguardhome

(参考网址)[https://developer.baidu.com/article/details/3252534]

```shell
mkdir -p /opt/data/file/adguardhome/work
mkdir -p /opt/data/file/adguardhome/conf
docker run \
  --name adguardhome \
  --restart=always \
  -p 6053:53/tcp \
  -p 6053:53/udp \
  -p 3000:3000/tcp \
  -v /opt/data/file/adguardhome/conf:/opt/adguardhome/conf \
  -v /opt/data/file/adguardhome/work:/opt/adguardhome/work \
  -d adguard/adguardhome
```

## NestingDNS(docker源找不到该项目)

DNS 三大神器 AdGuardHome、MosDNS、SmartDNS

(参考网址)[https://github.com/217heidai/NestingDNS]

```shell
mkdir -p /opt/data/file/nestingdns/etc
mkdir -p /opt/data/file/nestingdns/work
mkdir -p /opt/data/file/nestingdns/log

docker run \
    --restart unless-stopped \
    --name nestingdns \
    -p 3000:3000 \
    -p 4053:4053 \
    -p 4053:4053/udp \
    -v /opt/data/file/nestingdns/etc:/nestingdns/etc \
    -v /opt/data/file/nestingdns/work:/nestingdns/work \
    -v /opt/data/file/nestingdns/log:/nestingdns/log \
    -e TZ=Asia/Shanghai \
    -e SCHEDULE="0  4  *  *  *" \
    -d 217heidai/nestingdns

```

## 青龙面板

```shell
docker run -dit \
  --name qinglong \
  --hostname qinglong \
  --restart unless-stopped \
  -p 5700:5700 \
  -v /opt/data/file/qinglong/data:/ql/data \
  whyour/qinglong
```

## syncthing

```shell
docker run -d \
  --name syncthing \
  --restart always \
  -p 8384:8384 \
  -p 22000:22000/tcp \
  -p 22000:22000/udp \
  -p 21027:21027/udp \
  -e TZ=Asia/Shanghai \
  -v /opt/data/file/syncthing/config:/var/syncthing/config \
  -v /opt/data/file/syncthing/files:/var/syncthing/files \
  -v /opt/data/file/Pictures/Camera:/var/syncthing/Camera \
  -v /opt/data/file/Pictures/Screenshots:/var/syncthing/Screenshots \
  -v /opt/data/file/Pictures/Weixin:/var/syncthing/Weixin \
  -v /opt/data/file/Pictures/Collage:/var/syncthing/Collage \
  -v /opt/data/file/Pictures/Douyin:/var/syncthing/Douyin \
  syncthing/syncthing
```

## HomeAssistant

```shell
docker run -d \
  --name=homeassistant \
  --restart=unless-stopped \
  -p 8123:8123 \
  -v /opt/data/file/homeassistant:/config \
  -e TZ=Asia/Shanghai \
  ghcr.io/home-assistant/home-assistant:stable
```

## 迅雷

```shell
docker run -d \
  --name=xunlei \
  --restart=always \
  --privileged \
  -p 2345:2345 \
  -v /opt/data/file/xunlei:/xunlei/data \
  -v /opt/data/file/Downloads:/xunlei/downloads \
  cnk3x/xunlei
```

内测码`迅雷牛通`

使用 privileged 标志时，容器内的进程将具有以下能力：
1. 拥有访问主机上所有设备的权限。
2. 可以使用主机的所有内核功能。
3. 可以使用主机上所有的文件系统。

## it-tools

```shell
docker run -d \
  --name it-tools \
  --restart unless-stopped \
  -p 8080:80 \
  ghcr.io/corentinth/it-tools
```

## photoview

```shell
docker run -d \
  --restart unless-stopped \
  --name photoview \
  -p 8810:80 \
  -v /opt/data/file/photoview/cache:/app/cache \
  -v /opt/data/file/Pictures:/Pictures \
  -e PHOTOVIEW_DATABASE_DRIVER=mysql \
  -e PHOTOVIEW_MYSQL_URL=photoview:K2DjA2iWqtqg@tcp\(mysql:3306\)/photoview \
  -e PHOTOVIEW_MEDIA_CACHE=/app/cache \
  --link mysql \
  photoview/photoview
```

## moneynote

(参考网址)[https://github.com/getmoneynote/docker-compose-moneynote-ali]

```
docker run -d \
  --name moneynote \
  --restart unless-stopped \
  -p 43742:9092 \
  -p 43743:81 \
  -p 43744:82 \
  -e DB_HOST=mysql \
  -e DB_PORT=3306 \
  -e DB_NAME=moneynote \
  -e DB_USER=moneynote \
  -e DB_PASSWORD=K2DjA2iWqtqg \
  -e invite_code=moneynote \
  --link mysql \
  registry.cn-hangzhou.aliyuncs.com/moneynote/moneynote-all-no-mysql:latest
```
