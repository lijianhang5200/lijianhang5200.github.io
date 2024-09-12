---
layout: post
category: 运维
title: "ubuntuServer关闭显示器"
tag: [linux]
excerpt: ubuntuServer关闭显示器
---

## 操作

```shell
vi  /etc/default/grub
  consoleblank=0 # 增加
sudo update-grub
```

最后重启ubuntu。

中间如果无法修改grub文件，就chomd 777 grub,  修改grub权限

#### 参考地址

[https://www.jianshu.com/p/9c740952b70e](https://www.jianshu.com/p/9c740952b70e)
