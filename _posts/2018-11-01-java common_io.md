---
layout: post
category: 后端
title: "Apache Commons IO入门教程"
tag: [java]
excerpt: Apache Commons IO是Apache基金会创建并维护的Java函数库。
---

## 摘要

Apache Commons IO是Apache基金会创建并维护的Java函数库。

它提供了许多类使得开发者的常见任务变得简单，同时减少重复（boiler-plate）代码，这些代码可能遍布于每个独立的项目中，你却不得不重复的编写。这些类由经验丰富的开发者维护，对各种问题的边界条件考虑周到，并持续修复相关bug。

## Commons IO是针对开发IO流功能的工具类库。

### 主要包括六个区域：

- 工具类——使用静态方法执行共同任务
- 输入——用于InputStream和Reader实现
- 输出——用于OutputStream和Writer实现
- 过滤器——各种文件过滤器实现
- 比较器——各种文件的java.util.Comparator实现
- 文件监听器——监听文件系统事件的组件

## 使用实例

maven依赖

```xml
<dependency>
  <groupId>commons-io</groupId>
  <artifactId>commons-io</artifactId>
  <version>2.6</version>
</dependency>
```

## 工具类

### IOUtils

IOUtils包含处理读、写和复制的工具方法。方法对InputStream、OutputStream、Reader和Writer起作用。

**从一个URL读取字节的任务，并且打印它们**

常用JAVA操作

```java
InputStream in = new URL( "http://commons.apache.org"   ).openStream();
  try {
     InputStreamReader inR = new InputStreamReader( in );
     BufferedReader buf = new BufferedReader( inR );
     String line;
     while ( ( line = buf.readLine() ) != null ) {
       System.out.println( line );
     }
  } finally {
     in.close();
  }
```

IOUtils操作

```java
InputStream in = new URL( "http://commons.apache.org" ).openStream();
  try {
    System.out.println(IOUtils.toString(in));
  } finally {
    IOUtils.closeQuietly(in);
  }
```

在某些应用领域，这些IO操作是常见的，而这个类可以节省大量的时间。你可以依靠经过良好测试的代码。这样的实用程序代码，灵活性和速度是最重要的。**但是你也应该理解这种方法的局限性。使用上述技术读取一个1 gb文件将导致试图创建一个1 gb的字符串对象!**

### FileUtils

FileUtils类包含使用File对象的工具方法。包括读写、复制和比较稳健。

**读取整个文件行**

```java
File file = new File("/commons/io/project.properties");
List lines = FileUtils.readLines(file, "UTF-8");
```

### FilenameUtils

FilenameUtils类包含工具方法不需要使用File对象就可以操作文件名。该类致力于屏蔽Unix和Windows之间的不同，避免这些环境之间的转换（例如，从开发到生产）。

**规范文件删除双点片段**

```java
String filename = "C:/commons/io/../lang/project.xml";
```

### FileSystemUtils

FileSystemUtils类包含使用JDK不支持的文件系统访问功能的工具方法。当前，只有获取驱动的空间大小的方法。注意，这是使用的命令行，而不是本地代码。

```java
long freeSpace = FileSystemUtils.freeSpace("C:/");
```

### Endian类

不同的计算机体系采用不同的字节排序约定。在所谓的“Little Endian”的体系结构中（例如Intel），低位字节存储在内存中较低地址，后续字节在较高地址。对于“Big EndIan”体系结构，（例如Motorola），情况恰好相反。

在关联包中有两个类：

EndianUtils类包含交换Java原始和流的Endian-ness的静态方法。

SwappedDataInputStream类是DataInput接口的实现。使用它，我们能从非本地EndIan-ness的文件读取数据。

### 行迭代器

org.apache.commons.io.LineIterator类提供灵活的方式使用一个基于行的文件。可以直接，或通过FileUtils或IOUtils的工厂方法创建实例。推荐使用模式：

```java
  //处理行
  } finally {
    LineIterator.closeQuietly(iterator);
  }
```

### 文件比较器

org.apache.commons.io.comparator包提供一系列java.io.File的java.util.Comparator实现。这些比较器能用于排序文件列表和数组。

### 流

org.apache.commons.io.input和org.apache.commons.io.output包含各种有用的流实现。

- 空输出流——默默的吸收发给它的所有数据。
- Tee输出流——发送输出数据到两个流。
- 字节输出输出流——更便捷的JDK类版本。
- 计算流——统计传递的字节数。
- 代理流——委托恰当的方法代理。
- 可锁定的Writer——使用文件锁提供同步的Writer。

## 实例

### java.io.File

通常，你必须使用文件和文件名。有很多事情可能出错：

- 一个类可以在Unix上工作但不能在Windows上工作（反之亦然）
- 由于双重或丢失路径分隔符的无效路径
- UNC文件名（在Windows上）不使用我的本地文件名功能函数
- 等等

这些都是很好的理由不使用文件名作为字符串。使用java.io.File而不是处理上面的很多中情况。因此，我们最好的实践推荐使用java.io.File而不是文件名字符串避免平台依赖。

Commons-io 1.1包括一个专注于文件名处理的类——FilenameUtils。这处理许多这些文件名问题，然而，任然推荐，尽可能，使用java.io.File对象。

```java
public static String getExtension(String filename) {
  int index = filename.lastIndexOf('.');
  if (index == -1) {
    return "";
  } else {
    return filename.substring(index + 1);
  }
}
```

足够简单？对的，但如果传入一个完整路径而不是一个文件名会发生什么？请看下面，完全合法的路径：“C:\Temp\documentation.new\README”。定义在上面的方法返回“new\README”，肯定不是你想要的。

请使用java.io.File而不是字符串。在FileUtils你将看到围绕java.io.File的功能函数。

不推荐：

```java
String tmpdir = "/var/tmp";
String tmpfile = tmpdir + System.getProperty("file.separator") + "test.tmp";
InputStream in = new java.io.FileInputStream(tmpfile);
```

推荐：

```java
File tmpdir = new File("/var/tmp");
File tmpfile = new File(tmpdir, "test.tmp");
InputStream in = new java.io.FileInputStream(tmpfile);
```

### 缓冲流

IO性能依赖于缓冲策略。通常，读取大小为512或1024字节的数据包速度很快，因为这些大小匹配使用在硬盘上的文件系  统或文件系统缓冲中的数据包大小。但只要你多次只读取几个字节，性能肯定下降。

当你读取或输出流尤其是处理文件时确保你正确的缓冲流。只是使用BufferedInputStream装饰你的FileInputStream。

```java
InputStream in = new java.io.FileInputStream(myfile);
  try {
    in = new java.io.BufferedInputStream(in);
    in.read(.....
  } finally {
    IOUtils.closeQuietly(in);
  }
```

注意，不要缓冲已经缓冲的流。一些组件像XML解析器可以做自己的缓冲，因此不需要装饰InputStream传入XML解析器，但减慢你的代码。如果你使用CopyUtils或IOUtils不需要使用额外的缓冲流

### 获取文件信息

```java
System.out.println("Full path of exampleTxt: " + FilenameUtils.getFullPath(EXAMPLE_TXT_PATH));
System.out.println("Full name of exampleTxt: " + FilenameUtils.getName(EXAMPLE_TXT_PATH));
System.out.println("Extension of exampleTxt: " + FilenameUtils.getExtension(EXAMPLE_TXT_PATH));
System.out.println("Base name of exampleTxt: " + FilenameUtils.getBaseName(EXAMPLE_TXT_PATH));

FileEntry entry = new FileEntry(FileUtils.getFile(EXAMPLE_PATH));
System.out.println("File monitored: " + entry.getFile());
System.out.println("File name: " + entry.getName());
System.out.println("Is the file a directory?: " + entry.isDirectory());
```

### 判断父文件夹中是否包含指定子文件

```java
File parent = FileUtils.getFile(PARENT_DIR);
System.out.println("Parent directory contains exampleTxt file: " +
    FileUtils.directoryContains(parent, exampleFile));
```

### 字符比较操作

```java
String str1 = "This is a new String.";
String str2 = "This is another new String, yes!";
System.out.println("Ends with string (case sensitive): " +
    IOCase.SENSITIVE.checkEndsWith(str1, "string."));
System.out.println("Ends with string (case insensitive): " +
    IOCase.INSENSITIVE.checkEndsWith(str1, "string."));
System.out.println("String equality: " +
    IOCase.SENSITIVE.checkEquals(str1, str2));
```

### 按行读文件

```java
File exampleFile = FileUtils.getFile(EXAMPLE_TXT_PATH);
LineIterator iter = FileUtils.lineIterator(exampleFile);

System.out.println("Contents of exampleTxt...");
while (iter.hasNext()) {
  System.out.println("\t" + iter.next());
}
iter.close();
```

### 文件监视

```java
File parentDir = FileUtils.getFile(PARENT_DIR);

FileAlterationObserver observer = new FileAlterationObserver(parentDir);
observer.addListener(new FileAlterationListenerAdaptor() {
  @Override
  public void onFileCreate(File file) {
    System.out.println("File created: " + file.getName());
  }
  @Override
  public void onFileDelete(File file) {
    System.out.println("File deleted: " + file.getName());
  }
  @Override
  public void onDirectoryCreate(File dir) {
    System.out.println("Directory created: " + dir.getName());
  }
  @Override
  public void onDirectoryDelete(File dir) {
    System.out.println("Directory deleted: " + dir.getName());
  }
});
FileAlterationMonitor monitor = new FileAlterationMonitor(500, observer); // 单位： ms
try {
  monitor.start();

  // After we attached the monitor, we can create some files and directories
  // and see what happens!
  File newDir = new File(NEW_DIR);
  File newFile = new File(NEW_FILE);

  newDir.mkdirs();
  newFile.createNewFile();

  Thread.sleep(1000);

  FileDeleteStrategy.NORMAL.delete(newDir);
  FileDeleteStrategy.NORMAL.delete(newFile);

  Thread.sleep(1000);

  monitor.stop();
} catch (IOException e) {
  e.printStackTrace();
} catch (InterruptedException e) {
  e.printStackTrace();
} catch (Exception e) {
  e.printStackTrace();
}
```

### 文件过滤

```java
File dir = FileUtils.getFile(PARENT_DIR);
String[] acceptedNames = {"example", "exampleTxt.txt"};
for (String file: dir.list(new NameFileFilter(acceptedNames, IOCase.INSENSITIVE))) {
  System.out.println("File found, named: " + file);
}
```

### 通配符过滤

```java
File dir = FileUtils.getFile(PARENT_DIR);
for (String file: dir.list(new WildcardFileFilter("*ample*"))) {
  System.out.println("Wildcard file found, named: " + file);
}
```

### 前缀过滤

```java
File dir = FileUtils.getFile(PARENT_DIR);
for (String file: dir.list(new PrefixFileFilter("example"))) {
  System.out.println("Prefix file found, named: " + file);
}
```

### 后缀过滤

```java
File dir = FileUtils.getFile(PARENT_DIR);
for (String file: dir.list(new OrFileFilter(
        new WildcardFileFilter("*ample*"), new SuffixFileFilter(".txt")))) {
  System.out.println("Or file found, named: " + file);
}
```

### **包含和去除同时过滤**

```java
File dir = FileUtils.getFile(PARENT_DIR);
for (String file: dir.list(new AndFileFilter(
        new WildcardFileFilter("*ample*"),
        new NotFileFilter(new SuffixFileFilter(".txt"))))) {
  System.out.println("And/Not file found, named: " + file);
}
```

### 输入流转输出流

```java
TeeInputStream tee = null;
try {
  ByteArrayInputStream in = new ByteArrayInputStream(INPUT.getBytes("US-ASCII"));
  ByteArrayOutputStream out = new ByteArrayOutputStream();

  tee = new TeeInputStream(in, out, true);
  tee.read(new byte[INPUT.length()]);

  System.out.println("Output stream: " + out.toString());
} catch (IOException e) {
  e.printStackTrace();
} finally {
  try { tee.close(); }
  catch (IOException e) { e.printStackTrace(); }
}
```

### 输入流转多个输出流

```java
TeeInputStream teeIn = null;
TeeOutputStream teeOut = null;
try {
  // TeeOutputStream

  ByteArrayInputStream in = new ByteArrayInputStream(INPUT.getBytes("US-ASCII"));
  ByteArrayOutputStream out1 = new ByteArrayOutputStream();
  ByteArrayOutputStream out2 = new ByteArrayOutputStream();

  teeOut = new TeeOutputStream(out1, out2);
  teeIn = new TeeInputStream(in, teeOut, true);
  teeIn.read(new byte[INPUT.length()]);

  System.out.println("Output stream 1: " + out1.toString());
  System.out.println("Output stream 2: " + out2.toString());

} catch (IOException e) {
  e.printStackTrace();
} finally {
  try { teeIn.close(); }
  catch (IOException e) { e.printStackTrace(); }
}
```

### 文件排序

```java
File parentDir = FileUtils.getFile(PARENT_DIR);
NameFileComparator comparator = new NameFileComparator(IOCase.SENSITIVE);
File[] sortedFiles = comparator.sort(parentDir.listFiles());
System.out.println("Sorted by name files in parent directory: ");
for (File file: sortedFiles) {
  System.out.println("\t"+ file.getAbsolutePath());
}
```

### 文件大小排序

```java
SizeFileComparator sizeComparator = new SizeFileComparator(true);
File[] sizeFiles = sizeComparator.sort(parentDir.listFiles());

System.out.println("Sorted by size files in parent directory: ");
for (File file: sizeFiles) {
  System.out.println("\t"+ file.getName() + " with size (kb): " + file.length());
}
```

### 文件修改时间排序

```java
LastModifiedFileComparator lastModified = new LastModifiedFileComparator();
File[] lastModifiedFiles = lastModified.sort(parentDir.listFiles());

System.out.println("Sorted by last modified files in parent directory: ");
for (File file: lastModifiedFiles) {
  Date modified = new Date(file.lastModified());
  System.out.println("\t"+ file.getName() + " last modified on: " + modified);
}
```

### 获取指定两个文件修改时间

```java
File file1 = FileUtils.getFile(FILE_1);
File file2 = FileUtils.getFile(FILE_2);
if (lastModified.compare(file1, file2) > 0)
  System.out.println("File " + file1.getName() + " was modified last because...");
else
  System.out.println("File " + file2.getName() + "was modified last because...");

System.out.println("\t"+ file1.getName() + " last modified on: " +
    new Date(file1.lastModified()));
System.out.println("\t"+ file2.getName() + " last modified on: " +
    new Date(file2.lastModified()));
```
