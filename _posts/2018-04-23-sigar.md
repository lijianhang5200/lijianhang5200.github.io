---
layout: post
category: 后端
title:  "Sigar java监控系统信息"
tag: [java]
excerpt: 开源的跨平台系统信息收集工具，C语言实现,需要依赖库，推荐使用oshi。
---

### 简介

Sigar（System Information Gatherer And Reporter），开源的跨平台系统信息收集工具，C语言实现。

### 使用

Maven依赖

```xml
<dependency>
  <groupId>org.fusesource</groupId>
  <artifactId>sigar</artifactId>
  <veron>1.6.4</version>
</dependency>
<dependency>
  <groupId>org.kaazing</groupId>
  <artifactId>sigar.dist</artifactId>
  <version>1.0.0.0</version>
  <classifier>distribution</classifier>
  <type>zip</type>
</dependency>
```

### 添加Sigar 依赖的本地库文件

此处解释一下，与普通jar包不同，Sigar API还要依赖本地的库文件来进行工作，其中：

Windows下Sigar.jar 依赖：sigar-amd64-winnt.dll 或 sigar-x86-winnt.dll

Linux 下Sigar.jar依赖：libsigar-amd64-linux.so 或 libsigar-x86-linux.so

Sigar 通过java.library.path加载这些本地库文件，这些库文件同样可以在下载的压缩包中找到，官方给出的库文件更多，可以根据自己的跨平台需要选择。

**还有另一个库oshi可以使用,同样用于监控系统信息,不需要历来库文件** [链接地址](posts/2018/09/13/oshi.html)

Sigar这一点是不方便的，为了用几个API，每部署到一台电脑还要去折腾一遍库文件，想想就不能忍，还好发现了这篇博客！

下面是具体做法：

1. 将依赖库文件拷贝至项目某一目录下，此处我拷贝至web项目中的 //WebRoot/files/sigar 目录下
2. 在项目中通过代码获取此路径并将其添加至 java.library.path 中，下面是部分代码

```java
public class SigarUtils {
  public final static Sigar sigar = initSigar();
  private static Sigar initSigar() {
    try {
      //此处只为得到依赖库文件的目录，可根据实际项目自定义
      String file = Paths.get(PathKit.getWebRootPath(),  "files", "sigar",".sigar_shellrc").toString();
      File classPath = new File(file).getParentFile();

      String path = System.getProperty("java.library.path");
      String sigarLibPath = classPath.getCanonicalPath();
      //为防止java.library.path重复加，此处判断了一下
      if (!path.contains(sigarLibPath)) {
        if (isOSWin()) {
            path += ";" + sigarLibPath;
        } else {
            path += ":" + sigarLibPath;
        }
        System.setProperty("java.library.path", path);
      }
      return new Sigar();
    } catch (Exception e) {
      return null;
    }
  }

  public static boolean isOSWin(){//OS 版本判断
    String OS = System.getProperty("os.name").toLowerCase();
    if (OS.indexOf("win") >= 0) {
      return true;
    } else return false;
  }
}
```

终于可以用了

经过比一般jar包复杂N倍的折腾，终于能够用起来了，不过，Sigar 的javaAPI真的是又直观有简单又好用又全面有木有！！！
