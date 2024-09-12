---
layout: post
category: 后端
title:  "python stat模块概述"
tag: [python]
excerpt: 提供了一组用于访问文件或文件系统属性的函数和常量。
---

## 摘要

stat模块是Python标准库中的一部分，提供了一组用于访问文件或文件系统属性的函数和常量。它能够获取文件的各种属性，如文件大小、修改时间、权限等。通过使用stat模块，我们可以更方便地进行文件操作和管理。

## 常用函数

在stat模块中，常用的函数有：

- `stat(path)`：返回path指定的文件的状态信息；
- `lstat(path)`：类似于stat()，但是对于符号链接，返回链接本身的信息，而不是链接指向的文件的信息；
- `S_ISDIR(mode)`：判断给定的文件模式是否是目录；
- `S_ISREG(mode)`：判断给定的文件模式是否是普通文件；
- `S_ISLNK(mode)`：判断给定的文件模式是否是符号链接；
- `S_ISCHR(mode)`：判断给定的文件模式是否是字符设备文件；
- `S_ISBLK(mode)`：判断给定的文件模式是否是块设备文件；
- `S_ISSOCK(mode)`：判断给定的文件模式是否是套接字；
- `S_ISFIFO(mode)`：判断给定的文件模式是否是FIFO。

## 示例

下面是一个简单的代码示例，演示了如何使用stat模块获取文件的属性信息：

```python
import os
import stat

def get_file_info(file_path):
    file_stat = os.stat(file_path)
    mode = file_stat.st_mode
    size = file_stat.st_size
    mtime = file_stat.st_mtime

    if stat.S_ISDIR(mode):
        type_str = "目录"
    elif stat.S_ISREG(mode):
        type_str = "普通文件"
    elif stat.S_ISLNK(mode):
        type_str = "符号链接"
    elif stat.S_ISCHR(mode):
        type_str = "字符设备文件"
    elif stat.S_ISBLK(mode):
        type_str = "块设备文件"
    elif stat.S_ISSOCK(mode):
        type_str = "套接字"
    elif stat.S_ISFIFO(mode):
        type_str = "FIFO"
    else:
        type_str = "未知"

    print("文件路径：", file_path)
    print("文件类型：", type_str)
    print("文件大小：", size, "字节")
    print("修改时间：", mtime)

# 获取当前文件的属性信息
get_file_info(__file__)
```

以上代码首先使用os.stat()函数获取文件的状态信息，然后使用st_mode属性判断文件的类型。根据文件类型的不同，将其描述信息存储在type_str变量中。最后，将文件路径、类型、大小和修改时间打印出来。

运行结果

```shell
文件路径： /path/to/file.py
文件类型： 普通文件
文件大小： 100 字节
修改时间： 1612345678.0
```
