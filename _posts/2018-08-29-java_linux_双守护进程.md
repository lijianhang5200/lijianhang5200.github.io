---
layout: post
category: 后端
title: "Java实现Linux下双守护进程"
tag: [java, linux]
excerpt: Java实现Linux下双守护进程。
---

## 简介

现在的服务器端程序很多都是基于Java开发，针对于Java开发的Socket程序，这样的服务器端上线后出现问题需要手动重启，万一大半夜的挂了，还是特别麻烦的。

大多数的解决方法是使用其他进程来守护服务器程序，如果服务器程序挂了，通过守护进程来启动服务器程序。

万一守护进程挂了呢？使用双守护来提高稳定性，守护A负责监控服务器程序与守护B，守护B负责监控守护A，任何一方出现问题，都能快速的启动程序，提高服务器程序的稳定性。

Java的运行环境不同于C等语言开发的程序，Java程序跑在JVM上面。不同于C语言可以直接创建进程，Java创建一个进程等同于使用java -jar xxx.jar启动一个程序。

Java启动程序并没有C#类似的单实例限制，你可以启动多个，但是你不能启动多个，不能让多个守护A去守护服务器程序，万一启动了多个服务器程序怎么办？

## 技术讲解

这里的技术讲解比较粗略，具体请百度一下，这里只讲解作用。

1. jps命令。 

JDK自带的命令工具，使用jps -l可以列出正在运行的Java程序，显示Java程序的pid与Name。只对Java程序有效，其实查看的是运行的JVM

2. java.nio.channels.FileLock类的使用

这个是Java new IO中的类，使用他可以维持在读取文件的给文件加上锁，判断文件时候有锁可以判断该文件是否被其他的程序使用

3. ProcessBuilder与Process

这两个原理差不多，都是调用系统的命令运行，然后返回信息。但是硬编码会导致你的Java程序失去可移植性，可以将命令独立到配置文件中。

## 技术需求

- jps命令。

JDK自带的命令工具,使用jps -l可以列出正在运行的Java程序,显示Java程序的pid与Name。只对Java程序有效,其实查看的是运行的JVM

- java.nio.channels.FileLock类的使用

这个是Java new IO中的类,使用他可以维持在读取文件的给文件加上锁,判断文件时候有锁可以判断该文件是否被其他的程序使用

- ProcessBuilder与Process

这两个原理差不多,都是调用系统的命令运行,然后返回信息。但是硬编码会导致你的Java程序失去可移植性,可以将命令独立到配置文件中。

## 设计原理

Server:服务器程序

A:守护进程A

B:守护进程B

A.lock:守护进程A的文件锁

B.lock:守护进程B的文件锁

### Step 1

首先不考虑Server,只考虑A与B之间的守护

1. A判断B是否存活,没有就启动B
2. B判断A是否存活,没有就启动A
3. 在运行过程中A与B互相去拿对方的文件锁,如果拿到了,证明对面挂了,则启动对方。
4. A启动的时候,获取A.lock文件的锁,如果拿到了证明没有A启动,则A运行;如果没有拿到锁,证明A已经启动了,或者是B判断的时候拿到了锁,如果是A已经启动了,不需要再次启动A,如果是B判断的时候拿到了锁,没关紧 要,反正B会再次启动A。
5. B启动的时候原理与A一致。
6. 运行中如果A挂了,B判断到A已经挂了,则启动A。B同理。

### Step 2

加入Server

1. A用于守护B和Server,B用于守护A。
2. 原理与Step 1 一致,只是A多个一个守护Serer的任务。
3. 当A运行的时候,使用进程pid检测到Server已经挂了,就启动Server
4. 如果Server与A都挂了,B会启动A,然后A启动Server
5. 如果Server与B挂了,A启动Server与B
6. 如果A与B都挂了,守护结束

### Step 3

使用Shutdown结束守护,不然结束Server后会自动启动

## 实现

### GuardA的实现

```java
public class GuardA {
  // GuardA用于维持自己的锁
  private File fileGuardA;
  private FileOutputStream fileOutputStreamGuardA;
  private FileChannel fileChannelGuardA;
  private FileLock fileLockGuardA;

  // GuardB用于检测B的锁
  private File fileGuardB;
  private FileOutputStream fileOutputStreamGuardB;
  private FileChannel fileChannelGuardB;
  private FileLock fileLockGuardB;

  public GuardA() throws Exception {
    fileGuardA = new File(Configure.GUARD_A_LOCK);

    if (!fileGuardA.exists()) {
      fileGuardA.createNewFile();
    }

    //获取文件锁，拿不到证明GuardA已启动则退出
    fileOutputStreamGuardA = new FileOutputStream(fileGuardA);
    fileChannelGuardA = fileOutputStreamGuardA.getChannel();
    fileLockGuardA = fileChannelGuardA.tryLock();

    if (fileLockGuardA == null) {
      System.exit(0);
    }

    fileGuardB = new File(Configure.GUARD_B_LOCK);

    if (!fileGuardB.exists()) {
      fileGuardB.createNewFile();
    }

    fileOutputStreamGuardB = new FileOutputStream(fileGuardB);
    fileChannelGuardB = fileOutputStreamGuardB.getChannel();
  }

  /**
   * 检测B是否存在
   *
   * @return true B已经存在
   */
  public boolean checkGuardB() {
    try {
      fileLockGuardB = fileChannelGuardB.tryLock();

      if (fileLockGuardB == null) {
        return true;
      } else {
        fileLockGuardB.release();

        return false;
      }
    } catch (IOException e) {
      System.exit(0);

      // never touch
      return true;
    }
  }
}
```

### GuardServer的实现

```java
public class GuardServer {
  private String servername;

  public GuardServer(String servername) {
    this.servername = servername;
  }

  public void startServer(String cmd) throws Exception {
    System.out.println("Start Server : " + cmd);
    //将命令分开
    //        String[] cmds = cmd.split(" ");
    //        ProcessBuilder builder = new ProcessBuilder(cmds);

    //
    ProcessBuilder builder = new ProcessBuilder(new String[]{"/bin/sh", "-c", cmd});
    //将服务器程序的输出定位到/dev/tty
    builder.redirectOutput(new File("/dev/tty"));
    builder.redirectError(new File("/dev/tty"));
    builder.start(); // throws IOException
    Thread.sleep(10000);
  }

  /**
   * 检测服务是否存在
   *
   * @return 返回配置的java程序的pid
   * @return pid >0 返回的是 pid <=0 代表指定java程序未运行
   **/
  public int checkServer() throws Exception {
    int pid = -1;
    Process process = null;
    BufferedReader reader = null;
    process = Runtime.getRuntime().exec("jps -l");
    reader = new BufferedReader(new InputStreamReader(process.getInputStream()));
    String line;
    while ((line = reader.readLine()) != null) {
      String[] strings = line.split("\\s{1,}");
      if (strings.length < 2)
        continue;
      if (strings[1].contains(servername)) {
        pid = Integer.parseInt(strings[0]);
        break;
      }
    }
    reader.close();
    process.destroy();
    return pid;
  }
}
```

### GuardAMain实现

```java
public class GuardAMain {
  public static void main(String[] args) throws Exception {
    GuardA guardA = new GuardA();
    Configure configure = new Configure();
    GuardServer server = new GuardServer(configure.getServername());
    while (true) {
      // 如果GuardB未运行 运行GuardB
      if (!guardA.checkGuardB()) {
        System.out.println("Start GuardB.....");
        Runtime.getRuntime().exec(configure.getStartguardb());
      }
      // 检测服务器存活
      if (server.checkServer() <= 0) {
        boolean isServerDown = true;
        // trip check
        for (int i = 0; i < 3; i++) {
          // 如果服务是存活着
          if (server.checkServer() > 0) {
            isServerDown = false;
            break;
          }
        }
        if (isServerDown)
          server.startServer(configure.getStartserver());
      }
      Thread.sleep(configure.getInterval());
    }
  }
}
```

### Shutdown实现

```java
public class ShutDown {
  public static void main(String[] args) throws Exception {
    Configure configure = new Configure();
    System.out.println("Shutdown Guards..");
    for (int i = 0; i < 3; i++) {
      Process p = Runtime.getRuntime().exec("jps -l");
      BufferedReader reader = new BufferedReader(new InputStreamReader(p.getInputStream()));
      String line;
      while ((line = reader.readLine()) != null) {
        if (line.toLowerCase().contains("Guard".toLowerCase())) {
          String[] strings = line.split("\\s{1,}");
          int pid = Integer.parseInt(strings[0]);
          Runtime.getRuntime().exec(configure.getKillcmd() + " " + pid);
        }
      }
      p.waitFor();
      reader.close();
      p.destroy();
      Thread.sleep(2000);
    }
    System.out.println("Guards is shutdown");
  }
}
```

### GuardB与GuardA类似

#### 参考网址

[https://www.jb51.net/article/56790.htm](https://www.jb51.net/article/56790.htm)
