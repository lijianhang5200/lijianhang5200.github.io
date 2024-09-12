---
layout: post
category: 后端
title: "java Socket绑定网卡"
tag: [java, 网络编程]
excerpt: 在做java开发时有时会出现绑定的网卡不是自己需要的所以找到了以下的方法。
---

## 摘要

在做java开发时有时会出现绑定的网卡不是自己需要的所以找到了以下的方法。

## java代码

```java
public class App {
  public static void main(String[] args) throws InterruptedException, IOException, ParseException {
    Enumeration<NetworkInterface> networkInterfaces = NetworkInterface.getNetworkInterfaces();
    while (networkInterfaces.hasMoreElements()){
        NetworkInterface networkInterface = networkInterfaces.nextElement();
        System.out.println(networkInterface.getIndex() + ":" + networkInterface.getDisplayName());
    }

    NetworkInterface nif = NetworkInterface.getByIndex(2);
    Enumeration<InetAddress> nifAddresses = nif.getInetAddresses();

    System.out.println(nifAddresses.nextElement().getHostName());
    Socket socket = new Socket();
    socket.bind(new InetSocketAddress(nifAddresses.nextElement().getHostName(), 0));
    socket.connect(new InetSocketAddress("www.baidu.com", 80), 1000);
    String request = "GET /index.html HTTP/1.1\r\n"+
            "Host: www.baidu.com:80\r\n";
    PrintWriter pWriter = new PrintWriter(socket.getOutputStream(),true);
    pWriter.println(request);

    String tem;
    // 这里要注意二进制字节流转换为字符流编码要使用UTF-8
    BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(socket.getInputStream(), "utf-8"));
    while((tem = bufferedReader.readLine()) != null) {
        System.out.println(tem);
    }

    socket.close();
    }

}
```
