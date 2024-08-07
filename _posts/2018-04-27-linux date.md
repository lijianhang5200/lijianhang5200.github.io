---
layout: post
category: 运维
title:  "linux date命令的使用"
tag: [linux]
excerpt: linux 处理时间。
---

## 格式

```shell
date +%Y%m%d
# 命令参数
  -d<字符串>：显示字符串所指的日期与时间。字符串前后必须加上双引号；
  -s<字符串>：根据字符串来设置日期与时间。字符串前后必须加上双引号；
  -u：显示GMT；
  --help：在线帮助；
  --version：显示版本信息。
# 格式参数
  %H 小时（00..23）
  %I 小时（01..12）
  %k 小时（0..23）
  %l 小时（1..12）
  %M 分（00..59）
  %p 显示出AM或PM
  %r 时间（hh：mm：ss AM或PM），12小时
  %s 从1970年1月1日00：00：00到目前经历的秒数
  %S 秒（00..59）
  %T 时间（24小时制）（hh:mm:ss）
  %X 显示时间的格式（％H:％M:％S）
  %Z 时区 日期域
  %a 星期几的简称（ Sun..Sat）
  %A 星期几的全称（ Sunday..Saturday）
  %b 月的简称（Jan..Dec）
  %B 月的全称（January..December）
  %c 日期和时间（ Mon Nov 8 14：12：46 CST 1999）
  %d 一个月的第几天（01..31）
  %D 日期（mm／dd／yy）
  %  h 和%b选项相同
  %j 一年的第几天（001..366）
  %m 月（01..12）
  %w 一个星期的第几天（0代表星期天）
  %W 一年的第几个星期（00..53，星期一为第一天）
  %x 显示日期的格式（mm/dd/yy）
  %y 年的最后两个数字（ 1999则是99）
  %Y 年（例如：1970，1996等）
```

## 实例

```shell
# 格式化输出：
date +"%Y-%m-%d"
2015-12-07

# 输出昨天日期：
date -d "1 day ago" +"%Y-%m-%d"
2015-11-19

# 2秒后输出：
date -d "2 second" +"%Y-%m-%d %H:%M.%S"
2015-11-20 14:21.31

# 传说中的 1234567890 秒：
date -d "1970-01-01 1234567890 seconds" +"%Y-%m-%d %H:%m:%S"
2009-02-13 23:02:30

# 普通转格式：
date -d "2009-12-12" +"%Y/%m/%d %H:%M.%S"
2009/12/12 00:00.00

# apache格式转换：
date -d "Dec 5, 2009 12:00:37 AM" +"%Y-%m-%d %H:%M.%S"
2009-12-05 00:00.37

# 格式转换后时间：
date -d "Dec 5, 2009 12:00:37 AM 2 year ago" +"%Y-%m-%d %H:%M.%S"
2007-12-05 00:00.37

# 加减操作：
date +%Y%m%d               #显示前天年月日
date -d "+1 day" +%Y%m%d   #显示前一天的日期
date -d "-1 day" +%Y%m%d   #显示后一天的日期
date -d "-1 month" +%Y%m%d #显示上一月的日期
date -d "+1 month" +%Y%m%d #显示下一月的日期
date -d "-1 year" +%Y%m%d  #显示前一年的日期
date -d "+1 year" +%Y%m%d  #显示下一年的日期

# 设定时间：
date -s          #设置当前时间，只有root权限才能设置，其他只能查看
date -s 20120523 #设置成20120523，这样会把具体时间设置成空00:00:00
date -s 01:01:01 #设置具体时间，不会对日期做更改
date -s "01:01:01 2012-05-23" #这样可以设置全部时间
date -s "01:01:01 20120523"   #这样可以设置全部时间
date -s "2012-05-23 01:01:01" #这样可以设置全部时间
date -s "20120523 01:01:01"   #这样可以设置全部时间

# 检查一组命令花费的时间：
#!/bin/bash
start=$(date +%s)
nmap man.linuxde.net &> /dev/null
end=$(date +%s)
difference=$(( end - start ))
echo $difference seconds.
```
