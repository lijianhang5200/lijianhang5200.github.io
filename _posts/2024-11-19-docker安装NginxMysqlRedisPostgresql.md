---
layout: post
category: 运维
title: "docker安装nginx/mysql/redis/postgresql"
tag: [ docker, nas ]
excerpt: docker安装nginx/mysql/redis/postgresql。
---

## nginx

[参考网址](https://blog.csdn.net/breakaway_01/article/details/141299349)

```shell
docker run --name nginx -p 80:80 -d nginx:1.25.3
mkdir -p /opt/nginx
docker cp nginx:/etc/nginx/ /opt/nginx
docker cp nginx:/usr/share/nginx/html /opt/nginx
docker rm -f nginx
docker run \
  --name nginx \
  -p 80:80 \
  --restart=always \
  -v /opt/nginx/nginx/nginx.conf:/etc/nginx/nginx.conf \
  -v /opt/nginx/nginx/conf.d:/etc/nginx/conf.d \
  -v /opt/nginx/logs:/var/log/nginx \
  -v /opt/nginx/html:/usr/share/nginx/html \
  -v /opt/nginx/admin-top:/usr/share/nginx/admin-top \
  -d nginx:1.25.3
```

## registry 私有仓库容器

```shell
docker run -d \
  --name registry \
  --restart=always \
  -v /opt/registry:/var/lib/registry \
  -p 5000:5000 \
  registry:2
```

## mysql 8.4.3

[参考网址](https://blog.csdn.net/breakaway_01/article/details/141299349)

```shell
docker run -d \
  --name mysql \
  --restart=always \
  -e TZ=Asia/Shanghai \
  -e MYSQL_ROOT_PASSWORD=root \
  -v /opt/data/mysql/data:/var/lib/mysql \
  -v /opt/data/mysql/conf:/etc/mysql/conf.d \
  -v /opt/data/mysql/init:/docker-entrypoint-initdb.d \
  mysql:8.4.3
```

## redis

[参考网址](https://blog.csdn.net/qq_40104261/article/details/120738742)

```shell
mkdir -p /opt/redis/conf
cd /opt/redis/conf
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
  -v /opt/redis/conf/redis.conf:/etc/redis/redis.conf \
  -v /opt/redis/data:/data \
  -d redis:7.4 \
  redis-server /etc/redis/redis.conf --appendonly yes
```

## postgresql 15.8

[参考网址](https://zhuanlan.zhihu.com/p/606079311)

```shell
docker run \
  --name postgres \
  -e POSTGRES_PASSWORD=123456 \
  --restart=always \
  -v /opt/data/postgres/data:/var/lib/postgresql/data \
  -d postgres:15.8
```

## oracle11g 测试使用

```shell
# 创建容器
docker run -itd \
  --name oracle11204 \
  -h oracle11204 \
  --privileged=true  \
  -p 1521:1521  \
  -p 222:22   \
  -p 1158:1158 \
  xingyuyu123/oracle:oracle11204 init

# 进入容器
docker exec -it oracle11204 bash

# 启动数据库和监听
[root@oracle11204 /]# su - oracle
[oracle@oracle11204 ~]$ lsnrctl start
[oracle@oracle11204 ~]$ sqlplus / as sysdba
SYS@JEM11GR2> startup
SYS@JEM11GR2> select * from v$version;

# 外部连接容器内的数据库
sqlplus sys/jem@192.168.1.54:1521/JEM11GR2 AS SYSDBA
注意：此处访问宿主机端口为1521，容器内部是1521，端口映射,系统管理员密码为jem

# 修改sys密码
ALTER USER sys IDENTIFIED BY system;
#验证密码是否修改成功
commit;
exit
sqlplus sys/new_password as sysdba
```

## oracle21c(未测试)

[参考网址](https://github.com/Dark-Athena/dockerfile/tree/main/ol8_21_oml4py)

```shell
docker run -dit \
  --name ol8_21_con \
  -p 1521:1521 \
  -p 5500:5500 \
  --shm-size="1G" \
  -v /opt/oracle21c:/u02 \
  registry.cn-shanghai.aliyuncs.com/darkathena/ol8_21_oml4py:2.0
```

sys用户的默认登录密码为 SysPassword1

services_name=cdb1
services_name=pdb1

## gitea

```shell
docker run -d \
  --name gitea \
  --privileged=true  \
  --restart=always \
  -p 4000:3000 \
  -p 4022:22 \
  -e USER_UID=1000 \
  -e USER_GID=1000 \
  -e GITEA__database__DB_TYPE=mysql \
  -e GITEA__database__HOST=mysql:3306 \
  -e GITEA__database__NAME=gitea \
  -e GITEA__database__USER=gitea \
  -e GITEA__database__PASSWD=gitea \
  -v /opt/gitea:/data \
  -v /etc/timezone:/etc/timezone:ro \
  -v /etc/localtime:/etc/localtime:ro \
  --network mysql \
  gitea/gitea
```

## xxl-job-admin

[参考网址](https://blog.csdn.net/zhaoxichen_10/article/details/118446721)

```shell
mkdir -p /opt/xxl-job/admin/logs
docker run \
  --name xxl-job-admin \
  -p 18080:8080 \
  --restart=always \
  --network mysql \
  -e PARAMS="\
  --spring.datasource.url=jdbc:mysql://mysql:3306/xxl_job?Unicode=true&serverTimezone=Asia/Shanghai&characterEncoding=utf8&useUnicode=true&useSSL=false \
  --spring.datasource.username=root \
  --spring.datasource.password=root \
  --xxl.job.accessToken=123456" \
  -v /opt/xxl-job/admin/logs:/data/applogs \
  --privileged=true \
  -d xuxueli/xxl-job-admin:2.4.1
```

**页面访问**

打开浏览器，输入http://[宿主机的ip]:8080/xxl-job-admin
默认用户名及密码：admin/123456

## adguardhome

[参考网址](https://developer.baidu.com/article/details/3252534)

```shell
mkdir -p /opt/adguardhome/work
mkdir -p /opt/adguardhome/conf
docker run \
  --name adguardhome \
  --restart=always \
  -p 53:53/tcp \
  -p 53:53/udp \
  -p 3000:3000/tcp \
  -v /opt/adguardhome/conf:/opt/adguardhome/conf \
  -v /opt/adguardhome/work:/opt/adguardhome/work \
  -d adguard/adguardhome
```

## 青龙面板

```shell
docker run -dit \
  --name qinglong \
  --hostname qinglong \
  --restart=unless-stopped \
  -p 5700:5700 \
  -v /opt/qinglong/data:/ql/data \
  whyour/qinglong
```

## syncthing

```shell
docker run -d \
  --name syncthing \
  --restart=always \
  -p 8384:8384 \
  -p 22000:22000/tcp \
  -p 22000:22000/udp \
  -p 21027:21027/udp \
  -e TZ=Asia/Shanghai \
  -v /opt/syncthing/config:/var/syncthing/config \
  -v /opt/syncthing/files:/var/syncthing/files \
  -v /opt/Pictures/Camera:/var/syncthing/Camera \
  -v /opt/Pictures/Screenshots:/var/syncthing/Screenshots \
  -v /opt/Pictures/Weixin:/var/syncthing/Weixin \
  -v /opt/Pictures/Collage:/var/syncthing/Collage \
  -v /opt/Pictures/Douyin:/var/syncthing/Douyin \
  syncthing/syncthing
```

## HomeAssistant

```shell
docker run -d \
  --name=homeassistant \
  --restart=unless-stopped \
  -p 8123:8123 \
  -v /opt/homeassistant:/config \
  -e TZ=Asia/Shanghai \
  ghcr.io/home-assistant/home-assistant:stable
```

安装`HACS`插件

[https://github.com/hacs/integration/releases/](https://github.com/hacs/integration/releases/)

## 迅雷

```shell
docker run -d \
  --name=xunlei \
  --restart=unless-stopped \
  --privileged \
  -p 2345:2345 \
  -v /opt/xunlei:/xunlei/data \
  -v /opt/Downloads:/xunlei/downloads \
  cnk3x/xunlei
```

内测码`迅雷牛通`

使用 privileged 标志时，容器内的进程将具有以下能力：
1. 拥有访问主机上所有设备的权限。
2. 可以使用主机的所有内核功能。
3. 可以使用主机上所有的文件系统。

## nascab

[参考地址](https://www.nascab.cn/)

[下载地址](https://pan.baidu.com/e/1FiBdoAliwnOxzf7YuVDJIw?pwd=rjt2)

```shell
docker load -i nascab-docker-3.5.4-x64.tar
docker tag 镜像ID nascab:3.5.4
docker run -d \
  --name nascab \
  --restart=always \
  -p 8888:80 \
  -p 5555:90 \
  -v /data/Books:/root/Books \
  -v /data/Documents:/root/Documents \
  -v /data/Downloads:/root/Downloads \
  -v /data/Movies:/root/Movies \
  -v /data/Music:/root/Music \
  -v /data/Pictures:/root/Pictures \
  -v /data/Videos:/root/Videos \
  -v /data/privateSpace:/root/privateSpace \
  -v /opt/nascab:/root/.local/share/nascab \
  --log-opt max-size=128m \
  --log-opt max-file=3 \
  nascab:3.5.4
```

## samba

```
docker cp samba:/usr/bin/samba.sh /opt/samba/
docker run -itd \
  --name samba \
  --restart=always \
  -p 139:139 \
  -p 445:445 \
  -v /opt/samba/samba.sh:/usr/bin/samba.sh \
  -v /data/Books:/data/Books \
  -v /data/Documents:/data/Documents \
  -v /data/Downloads:/data/Downloads \
  -v /data/Movies:/data/Movies \
  -v /data/Music:/data/Music \
  -v /data/Pictures:/data/Pictures \
  -v /data/Videos:/data/Videos \
  dperson/samba -p \
  -u "lijianhang;lijianhang" \
  -s "home;/data/;yes;no;no;lijianhang;lijianhang;lijianhang" \
  -w "WORKGROUP" \
  -g "force user=lijianhang" \
  -g "guest account=lijianhang"
```

## moneynote

[参考网址](https://github.com/getmoneynote/docker-compose-moneynote-ali)

```
docker run -d \
  --name moneynote \
  --restart=always \
  -p 43742:9092 \
  -p 43743:81 \
  -p 43744:82 \
  -e DB_HOST=mysql \
  -e DB_PORT=3306 \
  -e DB_NAME=moneynote \
  -e DB_USER=moneynote \
  -e DB_PASSWORD=moneynote \
  -e invite_code=moneynote \
  --network mysql \
  moneynote/moneynote-all-no-mysql
```

## aipan

```shell
docker run -d \
  --name aipan \
  --restart=always \
  -p 3123:3000 \
  fooololo/aipan-netdisk-search
```
**注意**

镜像 unilei/aipan-netdisk-search 功能全没有在线播放

镜像 fooololo/aipan-netdisk-search 仅有网盘搜索+在线播放

## iptv-sources

[项目地址](https://github.com/HerbertHe/iptv-sources)

[参考网址](https://www.bilibili.com/video/BV1WZ421b76D/?vd_source=d38431766e665fda7c2ed5fb203e0a79)

```shell
docker run -d \
  --name iptv-sources \
  --restart always \
  -p 3088:8080 \
  herberthe0229/iptv-sources
```

```shell
docker exec -d iptv-sources /bin/sh ./update-sources.sh
crontab -e
二选一，或自己设定时间

①每两小时刷新一次：
0 */2 * * * /bin/sh ~/iptv-update.sh

②每天5点刷新一次：
0 5 * * * /bin/sh ~/iptv-update.sh
```

## watchtower

使用以下命令，更新宿主机的所有容器，也包括 Watch­tower 本身。

```shell
docker run -d  \
  --name watchtower \
  --restart always \
  --volume /var/run/docker.sock:/var/run/docker.sock \
  containrrr/watchtower --cleanup --interval 3600 ${容器名1} ${容器名2}
```

1. Watchtower 默认情况下 24 小时会检查一次镜像更新。设置--interval 选项更新时间，默认单位秒。
2. 可以使用--schedule选项， 设定定时更新任务，定时任务为6 字段来表示执行时间，第一个字段表示秒。
3. 可以使用--cleanup 选项，这样每次更新都会把旧的镜像清理掉。

## alist

```shell
docker run -d \
  --name alist \
  --restart=always \
  -p 5244:5244 \
  -v /opt/alist:/opt/alist/data \
  xhofe/alist

# 修改密码
docker exec -it alist ./alist admin
```

## aria2

```shell
docker run -d \
  --name=aria2 \
  --restart unless-stopped \
  -e TZ=Asia/Shanghai \
  -p 6080:80 \
  -p 6443:443 \
  -p 6800:6800 \
  -p 6881-6999:6881-6999 \
  -v /opt/aria2/aria2.conf:/etc/aria2.conf \
  -v /data/Downloads:/var/lib/aria2/downloads \
  snowdreamtech/aria2:webui
```

## 百度云盘

```shell
docker run -d \
  --name=baidunetdisk \
  -p 5800:5800 \
  -v /opt/baidunetdisk:/config \
  -v /data/Downloads:/config/baidunetdiskdownload \
  --restart unless-stopped \
  johngong/baidunetdisk:latest
```

## bitwarden

```
docker run -d \
  --name bitwarden \
  --restart on-failure \
  -v /opt/bitwarden:/data \
  -e WEBSOCKET_ENABLED=true \
  -e SIGNUPS_ALLOWED=true \
  -p 127:80 \
  -p 3012:3012 \
  vaultwarden/server
```

## vscode

```shell
docker run -itd \
  --name vscode \
  -p 9005:8080 \
  -e PASSWORD=123456 \
  -v /opt/vscode:/home/coder \
  codercom/code-server:opensuse
```

## instock

```shell
docker run -dit \
  --name instock \
  -p 9988:9988 \
  -e db_host=mysql \
  -e db_user=instockdb \
  -e db_password=instockdb \
  -e db_database=instockdb \
  -e db_port=3306 \
  --network mysql \
  mayanghua/instock
```

## nextcloud (不能进行多目录配置上传)

```shell
docker run -d \
  --name nextcloud \
  --restart=always \
  -p 8085:80 \
  -v /opt/nextcloud/data:/var/www/html/data \
  -v /opt/nextcloud/apps:/var/www/html/apps \
  -v /opt/nextcloud/config:/var/www/html/config \
  --network mysql \
  nextcloud
```

## openwrt

```shell
docker run -itd \
  --name=OneCloud \
  --restart=always \
  --network=macnet \
  --privileged=true \
  virking/openwrt:20.04 \
  /sbin/init
```

## openwebui

```
docker run -d \
  --name openwebui \
  --restart=always \
  -p 3080:8080 \
  -v /opt/openwebui:/app/backend/data \
  -e WEBUI_SECRET_KEY=123456 \
  -e OPENAI_API_BASE_URL=https://api.siliconflow.cn/v1 \
  -e OPENAI_API_KEY=sk-xxxx \
  -e DEFAULT_MODELS=deepseek-ai/DeepSeek-V3 \
  -e local_files_only=True \
  ghcr.io/open-webui/open-webui:main
```

## xiaomusic

```
docker run -d \
  --name xiaomusic \
  --restart=always \
  -p 8090:8090 \
  -v /opt/xiaomusic/music:/app/music \
  -v /opt/xiaomusic/conf:/app/conf \
  hanxi/xiaomusic
```

## mi-gpt

```shell
.env 参考 https://github.com/idootop/mi-gpt/blob/main/.env.example
echo "
OPENAI_MODEL=ep-xxxxxxxxx-gh4jr
OPENAI_API_KEY="xxxxx"
OPENAI_BASE_URL=https://ark.cn-beijing.volces.com/api/v3
" > /opt/migpt/.env
.migpt.js 参考 https://github.com/idootop/mi-gpt/blob/main/.migpt.example.js
echo "
// 小米ID
userId=""
// 账号密码
password="xxxxx"
// 小爱音箱did或在米家中设置名称
did= "小爱音箱Pro"
" > /opt/migpt/.migpt.js

docker run -d \
  --name migpt \
  --restart=always \
  --env-file /opt/migpt/.env \
  -v         /opt/migpt/.migpt.js:/app/.migpt.js \
  idootop/mi-gpt
```

## newsnow

```
docker run -d \
  --name newsnow \
  --restart=always \
  -p 4444:4444 \
  -e G_CLIENT_ID=  \
  -e G_CLIENT_SECRET=  \
  -e JWT_SECRET=  \
  -e INIT_TABLE=true \
  -e ENABLE_CACHE=true \
  ghcr.nju.edu.cn/ourongxing/newsnow
```

## win11

[参考地址](https://github.com/dockur/windows)

```shell
docker run -dit \
  --name win11 \
  -p 8006:8006 \
  -p 3389:3389/tcp \
  -p 3389:3389/udp \
  --device=/dev/kvm \
  --device=/dev/net/tun \
  --cap-add NET_ADMIN \
  --stop-timeout 120 \
  -e LANGUAGE="Chinese" \
  -e REGION="zh-CN" \
  -e KEYBOARD="zh-CN" \
  -e CPU_CORES="4" \
  -e RAM_SIZE="8G" \
  -e DISK_SIZE="64G" \
  -e USERNAME="Administrator" \
  -e PASSWORD="" \
  -e VERSION="11" \
  -v /opt/win11:/storage \
  -v /data:/data \
  dockurr/windows
```

--rm：容器停止自动删除容器

自定义iso,没有磁盘能够被选择安装

```shell
docker run -dit \
  --name win11j \
  -p 8007:8006 \
  -p 3390:3389/tcp \
  -p 3390:3389/udp \
  --device=/dev/kvm \
  --device=/dev/net/tun \
  --cap-add NET_ADMIN \
  --stop-timeout 120 \
  -e LANGUAGE="Chinese" \
  -e REGION="zh-CN" \
  -e KEYBOARD="zh-CN" \
  -e CPU_CORES="4" \
  -e RAM_SIZE="8G" \
  -e DISK_SIZE="64G" \
  -e USERNAME="Administrator" \
  -e PASSWORD="" \
  -v /opt/win11j:/storage \
  -v /data:/data \
  -v /data/Downloads/windows_iso/'【不忘初心游戏版】Windows11_23H2_22631.2861_X64_无更新[精简版][2.59G](2024.01.01).iso':/boot.iso \
  dockurr/windows
```

## Android(不好用)

```shell
docker run -d \
  --name android \
  -p 8007:6080 \
  --device /dev/kvm \
  -e EMULATOR_DEVICE="Samsung Galaxy S10" \
  -e WEB_VNC=true \
  budtmo/docker-android:emulator_11.0
```
  -v /opt/android:/home/androidusr \

## EasyNVR

```shell
docker run -d \
  --name easynvr \
  --restart always \
  --network host \
  --log-opt max-size=50M \
  -v "/opt/easynvr/configs:/app/configs" \
  -v "/opt/easynvr/logs:/app/logs" \
  -v "/opt/easynvr/temporary:/app/temporary" \
  -v "/opt/easynvr/r:/app/r" \
  -v "/opt/easynvr/stream:/app/stream" \
  registry.cn-shanghai.aliyuncs.com/rustc/easynvr_amd64
```

http://localhost:10000/

## xiaoya

```shell
docker run -d \
   --restart unless-stopped \
   --name xiaoya \
   -p 8765:80 \
   -v /opt/xiaoya/data:/data \
   xiaoyaliu/alist
```

## it-tools

```shell
docker run -d \
  --name it-tools \
  --restart=always \
  -p 8080:80 \
  ghcr.io/corentinth/it-tools
```

## splayer (替换为可以下载widows客户端)

[项目地址](https://github.com/imsyy/SPlayer)

可以下载windows应用

```shell
docker run -d \
  --name splayer \
  -p 25884:25884 \
  imsyy/splayer
```

## ChatGPT-Next-Web

私人 ChatGPT 网页应用，支持 GPT3, GPT4 & Gemini Pro 模型。

[参考地址](https://github.com/ChatGPTNextWeb/NextChat)

## datacap (数据中台，与预想功能不一致)

[操作文档](https://datacap.devlive.org/reference/getStarted/install.html)

[参考网址](https://datacap.devlive.org/reference/getStarted/installFromDockerCompose.html)

```shell
docker run -d \
  --name datacap \
  --restart unless-stopped \
  -p 9096:9096 \
  -v /opt/datacap/configure:/opt/app/datacap/configure \
  -v /opt/datacap/plugins:/opt/app/datacap/plugins \
  --network mysql \
  --link redis \
  --link postgres \
  devliveorg/datacap
```

| Username | Password |
| --- | --- |
| datacap | 123456789 |
| admin | 12345678 |



## melody (只能下载MP3，部分源不能使用，不推荐，替代为 splayer)

[项目地址](https://github.com/foamzou/melody)

```shell
docker run -d  \
  --name melody \
  --restart unless-stopped \
  -p 5566:5566 \
  -v /opt/melody:/app/backend/.profile \
  -v /opt/Music:/Music \
  foamzou/melody
```

可以看到需要填写melody key后才能开始使用，默认的 melody key 为： melody

## allinone (未测试)

```shell
docker run -d \
  --name allinone \
  --restart unless-stopped \
  --net=host \
  --privileged=true \
  -p 35455:35455 \
  youshandefeiyang/allinone

```

## photoview(已弃用，不能使用地点，替换为nascab)

```shell
docker run -d \
  --restart=always \
  --name photoview \
  -p 8810:80 \
  -v /opt/photoview/cache:/app/cache \
  -v /opt/Pictures:/Pictures \
  -e PHOTOVIEW_DATABASE_DRIVER=mysql \
  -e PHOTOVIEW_MYSQL_URL=photoview:photoview@tcp\(mysql:3306\)/photoview \
  -e PHOTOVIEW_MEDIA_CACHE=/app/cache \
  --network mysql \
  photoview/photoview
```

## 百度云(已不能使用，替代方案 alist)

[参考网址](https://blog.csdn.net/weixin_48714407/article/details/134598980)

[下载地址](https://pan.baidu.com/s/1VIRX7vLwMxYTch9cpN68-w?pwd=gwe1)

```shell
docker run -itd \
  --name baiduyunpan \
  --restart=unless-stopped \
  -p 5299:5299 \
  -v /opt/Downloads:/root/Downloads \
  baiyuetribe/baiduyunpan
```

## plantuml (改使用idea插件形式)

```shell
docker run -d \
  --name plantuml \
  --restart unless-stopped \
  -p 8284:8080 \
  plantuml/plantuml-server
```
