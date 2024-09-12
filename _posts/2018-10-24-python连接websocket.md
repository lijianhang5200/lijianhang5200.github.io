---
layout: post
category: 后端
title: "python连接websocket"
tag: [python]
excerpt: 模拟js端发送接收websocket数据。
---

## 介绍

模拟js端发送接收websocket数据

## 安装

```shell
pip install websocket-client
```

## python代码

```python
#-*- encoding:utf-8 -*-

import sys
sys.path.append("..")
from socket import *
import json, time, threading
from websocket import create_connection
reload(sys)
sys.setdefaultencoding("utf8")

# config = {
#   'HOST': '127.0.0.1',
#   'PORT': 10010
# }
#pip install websocket-client

class Client():
  def __init__(self):
    #调用create_connection方法，建立一个websocket链接,链接是自己的链接
    self.ws = create_connection("ws://127.0.0.1:10010/xxxx")
    #建一个线程，监听服务器发送给客户端的数据
    self.trecv = threading.Thread(target=self.recv)
    self.trecv.start()

  #发送方法，聊天输入语句时调用，此处默认为群聊ALL
  def send(self,content):
    #这里的msg要根据实际需要自己写
    msg={
      "type":"POST",
      "content":content
    }
    msg = json.dumps(msg)
    self.ws.send(msg)

  #接收服务端发送给客户的数据，只要ws处于连接状态，则一直接收数据
  def recv(self):
    try:
      while self.ws.connected:
        result = self.ws.recv()
        print "received msg:"+str(result)
    except Exception,e:
      pass

if __name__ == '__main__':

  c= Client()
  #建立链接后，就可以按照需要自己send了
  c.send(content)
```
