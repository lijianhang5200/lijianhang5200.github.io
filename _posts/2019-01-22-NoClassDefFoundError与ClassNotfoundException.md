---
layout: post
category: 后端
title: "NoClassDefFoundError与ClassNotfoundException探讨"
tag: [java]
excerpt: 这两个错误是完全不同的。
---

## 介绍

我们很容易把java.lang.NoClassDefFoundError和java.lang.ClassNotfoundException这两个错误搞混，事实上这两个错误是完全不同的。我们往往花费时间去不断尝试一些其他的方法去解决这个问题，而没有真正去理解这个错误的原因。

这篇文章就是通过解决NoClassDefFoundError错误处理的经验分享来揭开NoClassDefFoundError的一些秘密。NoClassDefFoundError的错误并非不能解决或者说很难解决，只是这种错误的表现形式很容易迷惑其他的Java开发者。

## NoClassDefFoundError错误发生的原因

NoClassDefFoundError错误的发生，是因为Java虚拟机在编译时能找到合适的类，而在运行时不能找到合适的类导致的错误。例如在运行时我们想调用某个类的方法或者访问这个类的静态成员的时候，发现这个类不可用，此时Java虚拟机就会抛出NoClassDefFoundError错误。与ClassNotFoundException的不同在于，这个错误发生只在运行时需要加载对应的类不成功，而不是编译时发生。

简单总结就是，NoClassDefFoundError发生在编译时对应的类可用，而运行时在Java的classpath路径中，对应的类不可用导致的错误。发生NoClassDefFoundError错误时，你能看到如下的错误日志：

```shell
Exception in thread "main" java.lang.NoClassDefFoundError
```

错误的信息很明显地指明main线程无法找到指定的类，而这个main线程可能时主线程或者其他子线程。如果是主线程发生错误，程序将崩溃或停止，而如果是子线程，则子线程停止，其他线程继续运行。

## NoClassDefFoundError和ClassNotFoundException区别

我们经常被java.lang.ClassNotFoundException和java.lang.NoClassDefFoundError这两个错误迷惑不清，尽管他们都与Java classpath有关，但是他们完全不同。NoClassDefFoundError发生在JVM在动态运行时，根据你提供的类名，在classpath中找到对应的类进行加载，但当它找不到这个类时，就发生了java.lang.NoClassDefFoundError的错误，而ClassNotFoundException是在编译的时候在classpath中找不到对应的类而发生的错误。

ClassNotFoundException比NoClassDefFoundError容易解决，是因为在编译时我们就知道错误发生，并且完全是由于环境的问题导致。而如果你在J2EE的环境下工作，并且得到NoClassDefFoundError的异常，而且对应的错误的类是确实存在的，这说明这个类对于类加载器来说，可能是不可见的。

## 怎么解决NoClassDefFoundError错误

根据前文，很明显NoClassDefFoundError的错误是因为在运行时类加载器在classpath下找不到需要加载的类，所以我们需要把对应的类加载到classpath中，或者检查为什么类在classpath中是不可用的，这个发生可能的原因如下：

1. 对应的Class在java的classpath中不可用
2. 你可能用jar命令运行你的程序，但类并没有在jar文件的manifest文件中的classpath属性中定义
3. 可能程序的启动脚本覆盖了原来的classpath环境变量
4. 因为NoClassDefFoundError是java.lang.LinkageError的一个子类，所以可能由于程序依赖的原生的类库不可用而导致
5. 检查日志文件中是否有java.lang.ExceptionInInitializerError这样的错误，NoClassDefFoundError有可能是由于静态初始化失败导致的
6. 如果你工作在J2EE的环境，有多个不同的类加载器，也可能导致NoClassDefFoundError

下面我们看一些当发生NoClassDefFoundError时，我们该如何解决的样例。

## NoClassDefFoundError解决示例

- 当发生由于缺少jar文件，或者jar文件没有添加到classpath，或者jar的文件名发生变更会导致java.lang.NoClassDefFoundError的错误。
- 当类不在classpath中时，这种情况很难确切的知道，但如果在程序中打印出System.getProperty(“java.classpath”)，可以得到程序实际运行的classpath
- 运行时明确指定你认为程序能正常运行的 -classpath 参数，如果增加之后程序能正常运行，说明原来程序的classpath被其他人覆盖了。
- NoClassDefFoundError也可能由于类的静态初始化模块错误导致，当你的类执行一些静态初始化模块操作，如果初始化模块抛出异常，哪些依赖这个类的其他类会抛出NoClassDefFoundError的错误。如果你查看程序日志，会发现一些java.lang.ExceptionInInitializerError的错误日志，ExceptionInInitializerError的错误会导致java.lang.NoClassDefFoundError: Could not initialize class，如下面的代码示例：

```java
/**
 * Java program to demonstrate how failure of static initialization subsequently cause
 * java.lang.NoClassDefFoundError in Java.
 * @author Javin Paul
 */
public class NoClassDefFoundErrorDueToStaticInitFailure {
  public static void main(String args[]){
    List<User> users = new ArrayList<User>(2);
    for(int i=0; i<2; i++){
      try{
      users.add(new User(String.valueOf(i))); //will throw NoClassDefFoundError
      }catch(Throwable t){
        t.printStackTrace();
      }
    }
  }
}

class User{
  private static String USER_ID = getUserId();

  public User(String id){
    this.USER_ID = id;
  }
  private static String getUserId() {
    throw new RuntimeException("UserId Not found");
  }
}
```

输出

```shell
java.lang.ExceptionInInitializerError
  at testing.NoClassDefFoundErrorDueToStaticInitFailure.main(NoClassDefFoundErrorDueToStaticInitFailure.java:23)
Caused by: java.lang.RuntimeException: UserId Not found
  at testing.User.getUserId(NoClassDefFoundErrorDueToStaticInitFailure.java:41)
  at testing.User.<clinit>(NoClassDefFoundErrorDueToStaticInitFailure.java:35)
  ... 1 more
java.lang.NoClassDefFoundError: Could not initialize class testing.User
  at testing.NoClassDefFoundErrorDueToStaticInitFailure.main(NoClassDefFoundErrorDueToStaticInitFailure.java:23)

Read more: http://javarevisited.blogspot.com/2011/06/noclassdeffounderror-exception-in.html#ixzz3dqtbvHDy
```

- 由于NoClassDefFoundError是LinkageError的子类，而LinkageError的错误在依赖其他的类时会发生，所以如果你的程序依赖原生的类库和需要的dll不存在时，有可能出现java.lang.NoClassDefFoundError。这种错误也可能抛出java.lang.UnsatisfiedLinkError: no dll in java.library.path Exception Java这样的异常。解决的办法是把依赖的类库和dll跟你的jar包放在一起。
- 如果你使用Ant构建脚本来生成jar文件和manifest文件，要确保Ant脚本获取的是正确的classpath值写入到manifest.mf文件
- Jar文件的权限问题也可能导致NoClassDefFoundError，如果你的程序运行在像linux这样多用户的操作系统种，你需要把你应用相关的资源文件，如Jar文件，类库文件，配置文件的权限单独分配给程序所属用户组，如果你使用了多个用户不同程序共享的jar包时，很容易出现权限问题。比如其他用户应用所属权限的jar包你的程序没有权限访问，会导致java.lang.NoClassDefFoundError的错误。
- 基于XML配置的程序也可能导致NoClassDefFoundError的错误。比如大多数Java的框架像Spring，Struts使用xml配置获取对应的bean信息，如果你输入了错误的名称，程序可能会加载其他错误的类而导致NoClassDefFoundError异常。我们在使用Spring MVC框架或者Apache Struts框架，在部署War文件或者EAR文件时就经常会出现Exception in thread “main” java.lang.NoClassDefFoundError。
- 在有多个ClassLoader的J2EE的环境中，很容易出现NoClassDefFoundError的错误。由于J2EE没有指明标准的类加载器，使用的类加载器依赖与不同的容器像Tomcat、WebLogic，WebSphere加载J2EE的不同组件如War包或者EJB-JAR包。关于类加载器的相关知识可以参考这篇文章类加载器的工作原理。

  总结来说，类加载器基于三个机制：委托、可见性和单一性，委托机制是指将加载一个类的请求交给父类加载器，如果这个父类加载器不能够找到或者加载这个类，那么再加载它。可见性的原理是子类的加载器可以看见所有的父类加载器加载的类，而父类加载器看不到子类加载器加载的类。单一性原理是指仅加载一个类一次，这是由委托机制确保子类加载器不会再次加载父类加载器加载过的类。现在假设一个User类在WAR文件和EJB-JAR文件都存在，并且被WAR ClassLoader加载，而WAR ClassLoader是加载EJB-JAR ClassLoader的子ClassLoader。当EJB-JAR中代码引用这个User类时，加载EJB-JAR所有class的Classloader找不到这个类，因为这个类已经被EJB-JAR classloader的子加载器WAR classloader加载。  

  这会导致的结果就是对User类出现NoClassDefFoundError异常，而如果在两个JAR包中这个User类都存在，如果你使用equals方法比较两个类的对象时，会出现ClassCastException的异常，因为两个不同类加载器加载的类无法进行比较。

- 有时候会出现Exception in thread “main” java.lang.NoClassDefFoundError: com/sun/tools/javac/Main 这样的错误，这个错误说明你的Classpath, PATH 或者 JAVA_HOME没有安装配置正确或者JDK的安装不正确。这个问题的解决办法时重新安装你的JDK。
- Java在执行linking操作的时候，也可能导致NoClassDefFoundError。例如在前面的脚本中，如果在编译完成之后，我们删除User的编译文件，再运行程序，这个时候你就会直接得到NoClassDefFoundError，而错误的消息只打印出User类的名称。

```java
java.lang.NoClassDefFoundError: testing/User
  at testing.NoClassDefFoundErrorDueToStaticInitFailure.main(NoClassDefFoundErrorDueToStaticInitFailure.java:23)
```
