---
layout: post
category: 运维
title:  "Oracle 11g 静默安装过程(CentOS 7 1810)内网安装(CentOS最小安装)"
tag: [oracle]
excerpt: 静默安装过程
---

## 在/etc/hosts文件中添加本机IP跟主机名

```shell
vi /etc/hosts
  192.168.80.130 oracle130
```

## 关闭selinux

```shell
vim /etc/selinux/config
  SELINUX=disabled # SELINUX=enforcing
```

## 关闭防火墙

```shell
systemctl status firewalld # 查看防火墙状态
systemctl stop firewalld # 停止防火墙
systemctl disable firewalld # 关闭自启动防火墙服务
```

## 配置本地yum源

挂载镜像文件CentOS-7-x86_64-Everything-1810.iso（找到光盘的完整路径）：

```shell
ls -l /dev | grep cdrom
mount /dev/cdrom /mnt/
df -h # 查看挂载状态：
cd /etc/yum.repos.d # 使用本地iso作为yum源
mv CentOS-Base.repo CentOS-Base.repo.bak
cp CentOS-Media.repo CentOS- Media.repo.bak
vi CentOS-Media.repo
  baseurl=file:///mnt/
  enabled = 1
yum clean all
```

这里多说一句：如果服务器不让插移动介质（比如移动硬盘、U盘之类的）也可以自行搭建内网YUM源，请参考：https://blog.csdn.net/edius12/article/details/79180014

## 安装unzip 工具、vim编辑器（个人习惯，vi也可以）

```shell
yum -y install unzip vim

```

## 安装Oracle 11g依赖包

```shell
yum -y install net-tools gcc make binutils gcc-c++ compat-libstdc++-33 elfutils-libelf-devel elfutils-libelf-devel-static elfutils-libelf-devel ksh libaio libaio-devel numactl-devel sysstat unixODBC unixODBC-devel pcre-devel
yum -y install binutils compat-libcap1 compat-libstdc++-33 compat-libstdc++-33*i686 compat-libstdc++-33*.devel compat-libstdc++-33 compat-libstdc++-33*.devel gcc gcc-c++ glibc glibc*.i686 glibc-devel glibc-devel*.i686 ksh libaio libaio*.i686 libaio-devel libaio-devel*.devel libgcc libgcc*.i686 libstdc++ libstdc++*.i686 libstdc++-devel libstdc++-devel*.devel libXi libXi*.i686 libXtst libXtst*.i686 make sysstat unixODBC unixODBC*.i686 unixODBC-devel unixODBC-devel*.i686

```

## 添加oinstall 、dba 组，新建oracle用户并加入oinstall、dba组中

```shell
groupadd oinstall
groupadd dba
useradd -g oinstall -G dba oracle
id oracle

```

## 修改内核参数

```shell
vim /etc/sysctl.conf
  io-max-nr = 1048576
  fs.file-max = 6815744
  kernel.shmall = 2097152
  kernel.shmmax = 1073741824
  kernel.shmmni = 4096
  kernel.sem = 250 32000 100 128
  net.ipv4.ip_local_port_range = 9000 65500
  net.core.rmem_default = 262144
  net.core.rmem_max = 4194304
  net.core.wmem_default = 262144
  net.core.wmem_max = 1048576
sysctl –p # 让参数生效(此处如果不行，可以reboot)
```

## 修改用户的限制文件

```shell
vim /etc/security/limits.conf
  oracle           soft    nproc           2047
  oracle           hard    nproc           16384
  oracle           soft    nofile          1024
  oracle           hard    nofile          65536
  oracle           soft    stack           10240
```

## 修改/etc/pam.d/login文件，添加：

```shell
vim /etc/pam.d/login
  session  required   /lib64/security/pam_limits.so
  session  required   pam_limits.so
```

## 修改/etc/profile文件：

```shell
vim /etc/profile
  if [ $USER = "oracle" ]; then
    if [ $SHELL = "/bin/ksh" ]; then
      ulimit -p 16384
      ulimit -n 65536
    else
      ulimit -u 16384 -n 65536
    fi
  fi
```

## 创建安装目录、修改文件权限

```shell
mkdir -p /u01/app/oracle/product/11.2.0
mkdir /u01/app/oracle/oradata
mkdir /u01/app/oracle/inventory
mkdir /u01/app/oracle/fast_recovery_area
chown -R oracle:oinstall /u01/app/oracle
chmod -R 775 /u01/app/oracle
```

## 解压oracle软件包

```shell
unzip linux.x64_11gR2_database_1of2.zip && unzip linux.x64_11gR2_database_2of2.zip
```

## 切换到oracle用户，设置oracle用户环境变量

```shell
[root@woitumi-197 database]# su - oracle
[oracle@woitumi-197 ~]$ vim .bash_profile
```

添加以下内容到.bash_profile最后。

```shell
ORACLE_BASE=/u01/app/oracle
ORACLE_HOME=$ORACLE_BASE/product/11.2.0
ORACLE_SID=orcl
PATH=$PATH:$ORACLE_HOME/bin
export ORACLE_BASE ORACLE_HOME ORACLE_SID PATH
```

## 编辑静默安装响应文件

切换到root 用户进入oracle安装包解压后的目录 /tmp/database/response/下备份db_install.rsp文件。

```shell
cp /tmp/database/response/db_install.rsp{,.bak}
```

编辑 /tmp/database/response/db_install.rsp文件

```shell
vim /tmp/database/response/db_install.rsp
# 修改以下配置
  oracle.install.option=INSTALL_DB_SWONLY
  ORACLE_HOSTNAME=woitumi-197
  UNIX_GROUP_NAME=oinstall
  INVENTORY_LOCATION=/u01/app/oracle/inventory
  SELECTED_LANGUAGES=en,zh_CN
  ORACLE_HOME=/u01/app/oracle/product/11.2.0
  ORACLE_BASE=/u01/app/oracle
  oracle.install.db.InstallEdition=EE
  oracle.install.db.DBA_GROUP=dba
  oracle.install.db.OPER_GROUP=dba
  DECLINE_SECURITY_UPDATES=true
```

## 根据响应文件安装oracle 11g

```shell
su - oracle
cd /tmp/database
./runInstaller -silent -ignorePrereq -ignoreSysPrereqs -responseFile /tmp/database/response/db_install.rsp
```
开始Oracle在后台静默安装。安装过程中，如果提示[WARNING]不必理会，此时安装程序仍在后台进行，如果出现[FATAL]，则安装程序已经停止了。

出现以上界面，说明安装程序已在后台运行，此时再打开另外一个终端选项卡，输入提示的会话日志目录：[root@woitumi-197 ~]# tail –f /u01/app/oracle/inventory/logs/installActions2017-06-09_03-00-09PM.log
看到日志文件会持续输出安装信息没有输入异常信息，则表明安装过程正常。
待看到下图内容，则表明安装已经完成

```shell

```

## 按照提示切换root用户运行脚本

```shell
sh /u01/app/oracle/inventory/orainstRoot.sh
sh /u01/app/oracle/product/11.2.0/root.sh
```

## 用oracle用户登录配置监听

```shell
netca -silent -responseFile /tmp/database/response/netca.rsp
```

## 出现下图情况时，则需要配置DISPLAY变量，配完之后重新netca：

```shell
[oracle@woitumi-197 ~]$ export DISPLAY=localhost:0.0
```













## 参考网址
Oracle 11g 静默安装过程（CentOS 7 1810）内网安装（CentOS最小安装）
https://blog.csdn.net/powrexly/article/details/96372380
解锁 scott 并 重置密码，
https://blog.csdn.net/hyj_king/article/details/104676350
自启配置
https://www.cnblogs.com/lightnear/archive/2012/10/10/2718737.html
oracle启动、关闭、重启脚本
https://www.cnblogs.com/cenliang/p/4836090.html
