---
layout: post
category: 运维
title:  "http迁移到https"
tag: [web, linux, nginx]
excerpt: 本文主要介绍利用 Let's Encrypt获取免费证书。
---

## 安装证书

本文主要介绍利用 Let's Encrypt获取免费证书。

使用 Let's Encrypt 证书，首先需要下载Certbot，下载地址如下：

[https://certbot.eff.org/](https://certbot.eff.org/)

对于不同的系统和服务器，该平台都有相对应的操作步骤说明。

安装好certbot后，就开始安装证书了。

首先，在网站根目录下创建一个.well-known的目录。这个目录，在安装证书的时候，certbot会进行访问。如下是在nginx默认的根目录创建.well-known目录。

```shell
mkdir -p /usr/share/nginx/html/.well-known
```

然后，安装证书。如下：

```shell
certbot certonly --webroot -w /usr/share/nginx/html -d test.example.com
```

上面test.example.com处，在你操作时请改为你自己的域名。

在安装的过程中，它会让你输入一些信息，比如邮箱地址，这时你按提示输入就好。根据提示进行操作，一般可以正常生产证书文件。证书文件存放在: '/etc/letsencrypt/live/test.example.com/'下。会有4个文件：

- cert.pem
- chain.pem
- fullchain.pem
- privkey.pem

## 配置服务器

证书安装完成后，就要开始配置服务器了，如下是配置nginx的操作：

```config
server {
  listen 443 ssl http2;
  server_name test.example.com;
  index index.html index.htm index.php;
  root /usr/share/nginx/html;

  ssl_sertificate      /etc/letsencrypt/live/test.example.com/fullchain.pem;
  ssl_certificate_key    /etc/letsencrypt/live/test.example.com/privkey.pem;

  ssl_ciphers HIGH:!aNULL:!MD5;
  ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
  ssl_prefer_server_ciphers on;
  ssl_session_cache shared:SSL:10m;

  access_log off;
}
```

## 重定向

nginx配置：

```config
server {
  listen 80;
  server_name domain.com www.domain.com;
  return 301 https://domain.com$request_uri;
}
```

apache配置：

```config
RewriteEngine On;
RewriteCond %{HTTPS} off;
RewriteRule (.\*) https://%{HTTP_HOST}%{REQUEST_URI} [R=301,L]
}
```

## 注意事项

需要注意的是：Let's Encrypt 的证书有效期为90天，因此，你必须定时更新证书，才能保证https长期正常。解决这个问题，你可以使用crontab定时器，如下：

```shell
10 6 * * * /bin/certbot renew --quiet &>/dev/null
```

到此时，https已经迁移完成。
