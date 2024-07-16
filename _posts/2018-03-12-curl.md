---
layout: post
category: 运维
title:  "linux curl命令的使用"
tag: [linux]
excerpt: cul是上传或下载文件的工具软件，它支持http,https,ftp,ftps,telnet等多种协议，常被用来抓取网页和监控Web服务器状态。
---

## 用法举例

### 抓取网页

抓取百度

```shell
curl http://www.baidu.com
```

如发现乱码，可以使用iconv转码

```shell
curl http://iframe.ip138.com/ic.asp|iconv -fgb2312
```

iconv的用法请参阅：在Linux/Unix系统下用iconv命令处理文本文件中文乱码问题

### 使用代理

使用http代理抓取页面

```shell
curl -x 111.95.243.36:80 http://iframe.ip138.com/ic.asp|iconv -fgb2312
curl -x 111.95.243.36:80 -U aiezu:password http://www.baidu.com
```

使用socks代理抓取页面

```shell
curl --socks4 202.113.65.229:443 http://iframe.ip138.com/ic.asp|iconv -fgb2312
curl --socks5 202.113.65.229:443 http://iframe.ip138.com/ic.asp|iconv -fgb2312
```

代理服务器地址可以从爬虫代理上获取。

### 处理cookies

接收cookies

```shell
curl -c /tmp/cookies http://www.baidu.com #cookies保存到/tmp/cookies文件
```

发送cookies

```shell
curl -b "key1=val1;key2=val2;" http://www.baidu.com #发送cookies文本
curl -b /tmp/cookies http://www.baidu.com #从文件中读取cookies
```

### 发送数据

get方式提交数据

```shell
curl -G -d "name=value&name2=value2" http://www.baidu.com
```

post方式提交数据

```shell
curl -d "name=value&name2=value2" http://www.baidu.com #post数据
curl -d a=b&c=d&txt@/tmp/txt http://www.baidu.com  #post文件
```

以表单的方式上传文件

```shell
curl -F file=@/tmp/me.txt http://www.aiezu.com
```

相当于设置form表单的method="POST"和enctype='multipart/form-data'两个属性。

### http header处理

设置http请求头信息

```shell
curl -A "Mozilla/5.0 Firefox/21.0" http://www.baidu.com #设置http请求头User-Agent
curl -e "http://pachong.org/" http://www.baidu.com #设置http请求头Referer
curl -H "Connection:keep-alive \n User-Agent: Mozilla/5.0" http://www.aiezu.com
```

设置http响应头处理

```shell
curl -I http://www.aiezu.com #仅仅返回header
curl -D /tmp/header http://www.aiezu.com #将http header保存到/tmp/header文件
```

### 认证

```shell
curl -u aiezu:password http://www.aiezu.com #用户名密码认证
# 通常的做法是在命令行只输入用户名，之后会提示输入密码，这样可以保证在查看历史记录时不会将密码泄露
curl -u username URL
curl -E mycert.pem https://www.baidu.com #采用证书认证
```

### 其他

```shell
curl -# http://www.baidu.com #以“#”号输出进度条
curl -o /tmp/aiezu http://www.baidu.com #保存http响应到/tmp/aiezu
```

### 下载单个文件

将文件下载到本地并命名为mygettext.html

```shell
curl -o mygettext.html http://www.gnu.org/software/gettext/manual/gettext.html
```

将文件保存到本地并命名为gettext.html

```shell
curl -O http://www.gnu.org/software/gettext/manual/gettext.html
```

同样可以使用转向字符">"对输出进行转向输出

### 同时获取多个文件

```shell
curl -O URL1 -O URL2
```

若同时从同一站点下载多个文件时，curl会尝试重用链接(connection)。

### 重定向

默认情况下CURL不会发送HTTP Location headers(重定向).

当一个被请求页面移动到另一个站点时，会发送一个HTTP Loaction header作为请求，然后将请求重定向到新的地址上。

例如：访问google.com时，会自动将地址重定向到google.com.hk上。

```shell
curl -L http://www.google.com # 让curl使用地址重定向，此时会查询google.com.hk站点
```

### 断点续传

当文件在下载完成之前结束该进程

```shell
curl -O http://www.gnu.org/software/gettext/manual/gettext.html
```

通过添加-C选项继续对该文件进行下载，已经下载过的文件不会被重新下载

```shell
curl -C - -O http://www.gnu.org/software/gettext/manual/gettext.html
```

### 网络限速

下载速度最大不会超过1000B/second

```shell
curl --limit-rate 1000B -O http://www.gnu.org/software/gettext/manual/gettext.html
```

### 下载指定时间内修改过的文件

当下载一个文件时，可对该文件的最后修改日期进行判断，如果该文件在指定日期内修改过，就进行下载，否则不下载。

```shell
# 若yy.html文件在2011/12/21之后有过更新才会进行下载
curl -z 21-Dec-11 http://www.example.com/yy.html
```

### 从FTP服务器下载文件

若在url中指定的是某个文件路径而非具体的某个要下载的文件名，CURL则会列出该目录下的所有文件名而并非下载该目录下的所有文件

```shell
# 列出public_html下的所有文件夹和文件
curl -u ftpuser:ftppass -O ftp://ftp_server/public_html/
# 下载xss.php文件
curl -u ftpuser:ftppass -O ftp://ftp_server/public_html/xss.php
```

### 上传文件到FTP服务器

将myfile.txt文件上传到服务器

```shell
curl -u ftpuser:ftppass -T myfile.txt ftp://ftp.testserver.com
```

同时上传多个文件

```shell
curl -u ftpuser:ftppass -T "{file1,file2}" ftp://ftp.testserver.com
```

从标准输入获取内容保存到服务器指定的文件中

```shell
curl -u ftpuser:ftppass -T - ftp://ftp.testserver.com/myfile_1.txt
```

## 小经验

http请求地址的url要使用""括起来。当有存在多个参数使用&连接时可能会出错。
