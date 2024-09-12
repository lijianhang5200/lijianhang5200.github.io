---
layout: post
category: 开发
title:  maven compiler插件
tag: [java]
excerpt: Compiler插件提供了如下2个goal，默认都已经绑定到Maven的生命周期阶段，无需单独指出。
---

## 概述

Compiler插件提供了如下2个goal，默认都已经绑定到Maven的生命周期阶段，无需单独指出。

compiler:compile，绑定到compile 阶段，用以编译main/路径下的源代码

compiler:testCompile，绑定到test-compile阶段，用以编译test/路径下的源代码

## 基本配置信息

```xml
<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-compiler-plugin</artifactId>
  <version>3.5.1</version>
</plugin>
```

## 使用的Java编译器

编译Java源代码就离不开Java编译器。

在Compiler插件3.0之前，默认的Java编译器就的JDK自带的javac。

但是从Compiler插件3.0开始（需要JDK 1.6），默认的Java编译器是javax.tools.JavaCompiler。

如果希望使用JDK自带的javac编译源代码，就需要为mvn命令配置forceJavacCompilerUse启动参数如下：

```shell
-Dmaven.compiler.forceJavacCompilerUse=true
```

## 设置Java编译器的执行参数

```xml
<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-compiler-plugin</artifactId>
  <version>3.5.1</version>
  <configuration>
    <compilerArgs>
      <arg>-verbose</arg>
      <arg>-Xlint:all,-options,-path</arg>
    </compilerArgs>
  </configuration>
</plugin>
```

## 设置使用其他JDK的编译器

```xml
<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-compiler-plugin</artifactId>
  <version>3.5.1</version>
  <configuration>
    <verbose>true</verbose>
    <fork>true</fork>
    <executable>${JAVA_1_8_HOME}/bin/javac</executable>
    <compilerVersion>1.6</compilerVersion>
  </configuration>
</plugin>
```

注意：上述配置中，用以编译Java源代码的是JDK 1.8,运行mvn命令的是JDK 1.6

## 设置要编译的Java源代码兼容的JVM版本和编译后的类库拟运行的JVM版本

```xml
<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-compiler-plugin</artifactId>
  <version>3.5.1</version>
  <configuration>
    <source>1.8</source>
    <target>1.8</target>
  </configuration>
</plugin>
```

## 设置可用的运行内存空间（Compiler插件的运行内存）

```xml
<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-compiler-plugin</artifactId>
  <version>3.5.1</version>
  <configuration>
    <fork>true</fork>
    <meminitial>128m</meminitial>
    <maxmem>512m</maxmem>
  </configuration>
</plugin>
```
