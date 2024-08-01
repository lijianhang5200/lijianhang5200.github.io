---
layout: post
category: 后端
title: "netty使用"
tag: [java, 网络编程]
excerpt: 由 JBOSS 提供的一个基于 JAVA NIO 类库的开源异步通信框架。
---

## 简介
由 JBOSS 提供的一个基于 JAVA NIO 类库的开源异步通信框架。

特点：异步非阻塞、基于事件驱动、高性能、高可靠性和高可定制性。

换句话说，Netty是一个NIO框架，使用它可以简单快速地开发网络应用程序，比如客户端和服务端的协议。

Netty大大简化了网络程序的开发过程比如TCP和UDP的 Socket的开发。

Netty 已逐渐成为 Java NIO 编程的首选框架

## 优点：

API 使用简单，开发门槛低；

功能强大，预置了多种编解码功能，支持多种主流协议；

定制能力强，可以通过 ChannelHandler 对通信框架进行灵活的扩展；

性能高，通过与其它业界主流的 NIO 框架对比，Netty 的综合性能最优；

社区活跃，版本迭代周期短，发现的 BUG 可以被及时修复，同时，更多的新功能会被加入；

经历了大规模的商业应用考验，质量得到验证。在互联网、大数据、网络游戏、企业应用、电信软件等众多行业得到成功商用，证明了它完全满足不同行业的商用标准。

## 代码示例

### pom依赖

```xml
<dependency>
  <groupId>io.netty</groupId>
  <artifactId>netty-all</artifactId>
  <version>4.1.0.Final</version>
</dependency>
```

## 简单示例

### SimpleServer（服务端）

```java
import io.netty.bootstrap.ServerBootstrap;
import io.netty.channel.ChannelFuture;
import io.netty.channel.ChannelInitializer;
import io.netty.channel.ChannelOption;
import io.netty.channel.EventLoopGroup;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.SocketChannel;
import io.netty.channel.socket.nio.NioServerSocketChannel;

/**
 *
 * Netty中，通讯的双方建立连接后，会把数据按照ByteBuf的方式进行传输，
 * 例如http协议中，就是通过HttpRequestDecoder对ByteBuf数据流进行处理，转换成http的对象。
 *
 */
public class SimpleServer {
  private int port;

  public SimpleServer(int port) {
    this.port = port;
  }

  public void run() throws Exception {
    //EventLoopGroup是用来处理IO操作的多线程事件循环器
    //bossGroup 用来接收进来的连接
    EventLoopGroup bossGroup = new NioEventLoopGroup();
    //workerGroup 用来处理已经被接收的连接
    EventLoopGroup workerGroup = new NioEventLoopGroup();
    try {
      //启动 NIO 服务的辅助启动类
      ServerBootstrap b = new ServerBootstrap();
      b.group(bossGroup, workerGroup)
        //配置 Channel
        .channel(NioServerSocketChannel.class)
        .childHandler(new ChannelInitializer<SocketChannel>() {
            @Override
            public void initChannel(SocketChannel ch) throws Exception {
              // 注册handler
              ch.pipeline().addLast(new SimpleServerHandler());
            }
          })
        .option(ChannelOption.SO_BACKLOG, 128)
        .childOption(ChannelOption.SO_KEEPALIVE, true);

      // 绑定端口，开始接收进来的连接
      ChannelFuture f = b.bind(port).sync();
      // 等待服务器 socket 关闭 。
      f.channel().closeFuture().sync();
    } finally {
      workerGroup.shutdownGracefully();
      bossGroup.shutdownGracefully();
    }
  }

  public static void main(String[] args) throws Exception {
    new SimpleServer(9999).run();
  }
}
```

### SimpleServerHandler（服务端请求处理Handler）

```java
import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.ChannelInboundHandlerAdapter;

public class SimpleServerHandler extends ChannelInboundHandlerAdapter {

  @Override
  public void channelRead(ChannelHandlerContext ctx, Object msg) throws Exception {
    System.out.println("SimpleServerHandler.channelRead");
    ByteBuf result = (ByteBuf) msg;
    byte[] result1 = new byte[result.readableBytes()];
    // msg中存储的是ByteBuf类型的数据，把数据读取到byte[]中
    result.readBytes(result1);
    String resultStr = new String(result1);
    // 接收并打印客户端的信息
    System.out.println("Client said:" + resultStr);
    // 释放资源，这行很关键
    result.release();

    // 向客户端发送消息
    String response = "hello client!";
    // 在当前场景下，发送的数据必须转换成ByteBuf数组
    ByteBuf encoded = ctx.alloc().buffer(4 * response.length());
    encoded.writeBytes(response.getBytes());
    ctx.write(encoded);
    ctx.flush();
  }

  @Override
  public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) throws Exception {
    // 当出现异常就关闭连接
    cause.printStackTrace();
    ctx.close();
  }

  @Override
  public void channelReadComplete(ChannelHandlerContext ctx) throws Exception {
    ctx.flush();
  }

}
```

### SimpleServer（客户端）

```java
import io.netty.bootstrap.Bootstrap;
import io.netty.bootstrap.ServerBootstrap;
import io.netty.channel.ChannelFuture;
import io.netty.channel.ChannelInitializer;
import io.netty.channel.ChannelOption;
import io.netty.channel.EventLoopGroup;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.SocketChannel;
import io.netty.channel.socket.nio.NioServerSocketChannel;
import io.netty.channel.socket.nio.NioSocketChannel;

public class SimpleClient {

  public void connect(String host, int port) throws Exception {
    EventLoopGroup workerGroup = new NioEventLoopGroup();

    try {
      Bootstrap b = new Bootstrap();
      b.group(workerGroup);
      b.channel(NioSocketChannel.class);
      b.option(ChannelOption.SO_KEEPALIVE, true);
      b.handler(new ChannelInitializer<SocketChannel>() {
        @Override
        public void initChannel(SocketChannel ch) throws Exception {
          ch.pipeline().addLast(new SimpleClientHandler());
        }
      });

      // Start the client.
      ChannelFuture f = b.connect(host, port).sync();

      // Wait until the connection is closed.
      f.channel().closeFuture().sync();
    } finally {
      workerGroup.shutdownGracefully();
    }
  }

  public static void main(String[] args) throws Exception {
    SimpleClient client=new SimpleClient();
    client.connect("127.0.0.1", 9999);
  }

}
```

## 进阶示例

### 服务端

```java
import io.netty.bootstrap.ServerBootstrap;
import io.netty.channel.ChannelFuture;
import io.netty.channel.ChannelHandler;
import io.netty.channel.ChannelInitializer;
import io.netty.channel.ChannelOption;
import io.netty.channel.EventLoopGroup;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.SocketChannel;
import io.netty.channel.socket.nio.NioServerSocketChannel;

/**
 * 1. 双线程组
 * 2. Bootstrap配置启动信息
 * 3. 注册业务处理Handler
 * 4. 绑定服务监听端口并启动服务
 */

public class Server4HelloWorld {
  // 监听线程组，监听客户端请求
  private EventLoopGroup acceptorGroup = null;
  // 处理客户端相关操作线程组，负责处理与客户端的数据通讯
  private EventLoopGroup clientGroup = null;
  // 服务启动相关配置信息
  private ServerBootstrap bootstrap = null;
  public Server4HelloWorld(){
    init();
  }
  private void init(){
    // 初始化线程组,构建线程组的时候，如果不传递参数，则默认构建的线程组线程数是CPU核心数量。
    acceptorGroup = new NioEventLoopGroup();
    clientGroup = new NioEventLoopGroup();
    // 初始化服务的配置
    bootstrap = new ServerBootstrap();
    // 绑定线程组
    bootstrap.group(acceptorGroup, clientGroup);
    // 设定通讯模式为NIO， 同步非阻塞
    bootstrap.channel(NioServerSocketChannel.class);
    // 设定缓冲区大小， 缓存区的单位是字节。
    bootstrap.option(ChannelOption.SO_BACKLOG, 1024);
    // SO_SNDBUF发送缓冲区，SO_RCVBUF接收缓冲区，SO_KEEPALIVE开启心跳监测（保证连接有效）
    bootstrap.option(ChannelOption.SO_SNDBUF, 16*1024)
      .option(ChannelOption.SO_RCVBUF, 16*1024)
      .option(ChannelOption.SO_KEEPALIVE, true);
  }
  /**
   * 监听处理逻辑。
   * @param port 监听端口。
   * @param acceptorHandlers 处理器， 如何处理客户端请求。
   * @return
   * @throws InterruptedException
   */
  public ChannelFuture doAccept(int port, final ChannelHandler... acceptorHandlers) throws InterruptedException{

    /*
     * childHandler是服务的Bootstrap独有的方法。是用于提供处理对象的。
     * 可以一次性增加若干个处理逻辑。是类似责任链模式的处理方式。
     * 增加A，B两个处理逻辑，在处理客户端请求数据的时候，根据A-》B顺序依次处理。
     *
     * ChannelInitializer - 用于提供处理器的一个模型对象。
     *  其中定义了一个方法，initChannel方法。
     *   方法是用于初始化处理逻辑责任链条的。
     *   可以保证服务端的Bootstrap只初始化一次处理器，尽量提供处理逻辑的重用。
     *   避免反复的创建处理器对象。节约资源开销。
     */
    bootstrap.childHandler(new ChannelInitializer<SocketChannel>() {

      @Override
      protected void initChannel(SocketChannel ch) throws Exception {
        ch.pipeline().addLast(acceptorHandlers);
      }
    });
    // bind方法 - 绑定监听端口的。ServerBootstrap可以绑定多个监听端口。 多次调用bind方法即可
    // sync - 开始监听逻辑。 返回一个ChannelFuture。 返回结果代表的是监听成功后的一个对应的未来结果
    // 可以使用ChannelFuture实现后续的服务器和客户端的交互。
    ChannelFuture future = bootstrap.bind(port).sync();
    return future;
  }

  /**
   * shutdownGracefully - 方法是一个安全关闭的方法。可以保证不放弃任何一个已接收的客户端请求。
   */
  public void release(){
    this.acceptorGroup.shutdownGracefully();
    this.clientGroup.shutdownGracefully();
  }

  public static void main(String[] args){
    ChannelFuture future = null;
    Server4HelloWorld server = null;
    try{
      server = new Server4HelloWorld();
      future = server.doAccept(9999,new Server4HelloWorldHandler());
      System.out.println("server started.");

      // 关闭连接的。
      future.channel().closeFuture().sync();
    }catch(InterruptedException e){
      e.printStackTrace();
    }finally{
      if(null != future){
        try {
          future.channel().closeFuture().sync();
        } catch (InterruptedException e) {
          e.printStackTrace();
        }
      }

      if(null != server){
        server.release();
      }
    }
  }

}
```

```java
import io.netty.buffer.ByteBuf;
import io.netty.buffer.Unpooled;
import io.netty.channel.ChannelHandler.Sharable;
import io.netty.channel.ChannelHandlerAdapter;
import io.netty.channel.ChannelHandlerContext;

/**
 * @Sharable注解 -
 *  代表当前Handler是一个可以分享的处理器。也就意味着，服务器注册此Handler后，可以分享给多个客户端同时使用。
 *  如果不使用注解描述类型，则每次客户端请求时，必须为客户端重新创建一个新的Handler对象。
 *  如果handler是一个Sharable的，一定避免定义可写的实例变量。
 *  bootstrap.childHandler(new ChannelInitializer<SocketChannel>() {
      @Override
      protected void initChannel(SocketChannel ch) throws Exception {
        ch.pipeline().addLast(new XxxHandler());
      }
    });
 */

@Sharable
public class Server4HelloWorldHandler extends ChannelHandlerAdapter {

  /**
   * 业务处理逻辑
   * 用于处理读取数据请求的逻辑。
   * ctx - 上下文对象。其中包含于客户端建立连接的所有资源。 如： 对应的Channel
   * msg - 读取到的数据。 默认类型是ByteBuf，是Netty自定义的。是对ByteBuffer的封装。 不需要考虑复位问题。
   */
  @Override
  public void channelRead(ChannelHandlerContext ctx, Object msg) throws Exception {
    /*获取读取的数据， 是一个缓冲。*/
    ByteBuf readBuffer = (ByteBuf) msg;
    // 创建一个字节数组，用于保存缓存中的数据。
    byte[] tempDatas = new byte[readBuffer.readableBytes()];
    // 将缓存中的数据读取到字节数组中。/**/
    readBuffer.readBytes(tempDatas);
    String message = new String(tempDatas, "UTF-8");
    System.out.println("from client : " + message);
    if("exit".equals(message)){
      ctx.close();
      return;
    }
    String line = "server message to client!";
    // 写操作自动释放缓存，避免内存溢出问题。
    ctx.writeAndFlush(Unpooled.copiedBuffer(line.getBytes("UTF-8")));
    // 注意，如果调用的是write方法。不会刷新缓存，缓存中的数据不会发送到客户端，必须再次调用flush方法才行。
    // ctx.write(Unpooled.copiedBuffer(line.getBytes("UTF-8")));
    // ctx.flush();
  }

  /**
   * 异常处理逻辑， 当客户端异常退出的时候，也会运行。
   * ChannelHandlerContext关闭，也代表当前与客户端连接的资源关闭。
   */
  @Override
  public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) throws Exception {
    System.out.println("server exceptionCaught method run...");
    // cause.printStackTrace();
    ctx.close();
  }

}
```

### 客户端

```java
import java.util.Scanner;
import java.util.concurrent.TimeUnit;
import io.netty.bootstrap.Bootstrap;
import io.netty.buffer.Unpooled;
import io.netty.channel.ChannelFuture;
import io.netty.channel.ChannelFutureListener;
import io.netty.channel.ChannelHandler;
import io.netty.channel.ChannelInitializer;
import io.netty.channel.EventLoopGroup;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.SocketChannel;
import io.netty.channel.socket.nio.NioSocketChannel;

/**
 * 1. 单线程组
 * 2. Bootstrap配置启动信息
 * 3. 注册业务处理Handler
 * 4. connect连接服务，并发起请求
 *
 * 因为客户端是请求的发起者，不需要监听。
 * 只需要定义唯一的一个线程组即可。
 */
public class Client4HelloWorld {

  // 处理请求和处理服务端响应的线程组
  private EventLoopGroup group = null;
  // 客户端启动相关配置信息
  private Bootstrap bootstrap = null;

  public Client4HelloWorld(){
    init();
  }

  private void init(){
    group = new NioEventLoopGroup();
    bootstrap = new Bootstrap();
    // 绑定线程组
    bootstrap.group(group);
    // 设定通讯模式为NIO
    bootstrap.channel(NioSocketChannel.class);
  }

  public ChannelFuture doRequest(String host, int port, final ChannelHandler... handlers) throws InterruptedException{
    /*
     * 客户端的Bootstrap没有childHandler方法。只有handler方法。
     * 方法含义等同ServerBootstrap中的childHandler
     * 在客户端必须绑定处理器，也就是必须调用handler方法。
     * 服务器必须绑定处理器，必须调用childHandler方法。
     */
    this.bootstrap.handler(new ChannelInitializer<SocketChannel>() {
      @Override
      protected void initChannel(SocketChannel ch) throws Exception {
        ch.pipeline().addLast(handlers);
      }
    });
    // 建立连接。
    ChannelFuture future = this.bootstrap.connect(host, port).sync();
    return future;
  }

  public void release(){
    this.group.shutdownGracefully();
  }

  public static void main(String[] args) {
    Client4HelloWorld client = null;
    ChannelFuture future = null;
    try{
      client = new Client4HelloWorld();
      future = client.doRequest("localhost", 9999, new Client4HelloWorldHandler());

      Scanner s = null;
      while(true){
        s = new Scanner(System.in);
        System.out.print("enter message send to server (enter 'exit' for close client) > ");
        String line = s.nextLine();
        if("exit".equals(line)){
          // addListener - 增加监听，当某条件满足的时候，触发监听器。
          // ChannelFutureListener.CLOSE - 关闭监听器，代表ChannelFuture执行返回后，关闭连接。
          future.channel().writeAndFlush(Unpooled.copiedBuffer(line.getBytes("UTF-8")))
            .addListener(ChannelFutureListener.CLOSE);
          break;
        }
        future.channel().writeAndFlush(Unpooled.copiedBuffer(line.getBytes("UTF-8")));
        TimeUnit.SECONDS.sleep(1);
      }
    }catch(Exception e){
      e.printStackTrace();
    }finally{
      if(null != future){
        try {
          future.channel().closeFuture().sync();
        } catch (InterruptedException e) {
          e.printStackTrace();
        }
      }
      if(null != client){
        client.release();
      }
    }
  }
}
```
```java
import io.netty.channel.ChannelHandlerAdapter;
import io.netty.channel.ChannelHandlerContext;
import io.netty.util.ReferenceCountUtil;

public class Client4DelimiterHandler extends ChannelHandlerAdapter {

  @Override
  public void channelRead(ChannelHandlerContext ctx, Object msg) throws Exception {
    try{
      String message = msg.toString();
      System.out.println("from server : " + message);
    }finally{
      // 用于释放缓存。避免内存溢出
      ReferenceCountUtil.release(msg);
    }
  }

  @Override
  public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) throws Exception {
    System.out.println("client exceptionCaught method run...");
    // cause.printStackTrace();
    ctx.close();
  }

}
```

## 线程模型

Netty 中支持单线程模型,多线程模型,主从多线程模型。

### 单线程模型

在 ServerBootstrap 调用方法 group 的时候,传递的参数是同一个线程组,且在构造线程组的时候,构造参数为 1,这种开发方式,就是一个单线程模型。

个人机开发测试使用。不推荐。

### 多线程模型

在 ServerBootstrap 调用方法 group 的时候,传递的参数是两个不同的线程组。负责监听的 acceptor 线程组,线程数为 1,也就是构造参数为 1。负责处理客户端任务的线程组,线程数大于 1,也就是构造参数大于 1。这种开发方式,就是多线程模型。

长连接,且客户端数量较少,连接持续时间较长情况下使用。如:企业内部交流应用。

### 主从多线程模型

在 ServerBootstrap 调用方法 group 的时候,传递的参数是两个不同的线程组。负责监听的 acceptor 线程组,线程数大于 1,也就是构造参数大于 1。负责处理客户端任务的线程组,线程数大于 1,也就是构造参数大于 1。这种开发方式,就是主从多线程模型。

长连接,客户端数量相对较多,连接持续时间比较长的情况下使用。如:对外提供服务的相册服务器。

## 拆包粘包问题解决

netty 使用 tcp/ip 协议传输数据。而 tcp/ip 协议是类似水流一样的数据传输方式。多次访问的时候有可能出现数据粘包的问题,解决这种问题的方式如下:

### 定长数据流

客户端和服务器,提前协调好,每个消息长度固定。(如:长度 10)。如果客户端或服务器写出的数据不足 10,则使用空白字符补足(如:使用空格)。

### 特殊结束符

客户端和服务器,协商定义一个特殊的分隔符号,分隔符号长度自定义。如:‘ #’、‘$_$’、‘AA@’。在通讯的时候,只要没有发送分隔符号,则代表一条数据没有结束。

### 协议

相对最成熟的数据传递方式。有服务器的开发者提供一个固定格式的协议标准。客户端和服务器发送数据和接受数据的时候,都依据协议制定和解析消息。

## 序列化对象

JBoss Marshalling 序列化

Java 是面向对象的开发语言。传递的数据如果是 Java 对象,应该是最方便且可靠。

## 定时断线重连

客户端断线重连机制。

客户端数量多,且需要传递的数据量级较大。可以周期性的发送数据的时候,使用。要求对数据的即时性不高的时候,才可使用。

优点: 可以使用数据缓存。不是每条数据进行一次数据交互。可以定时回收资源,对资源利用率高。相对来说,即时性可以通过其他方式保证。如: 120 秒自动断线。数据变化 1000 次请求服务器一次。300 秒中自动发送不足 1000 次的变化数据。

## 心跳监测

使用定时发送消息的方式,实现硬件检测,达到心态检测的目的。

心跳监测是用于检测电脑硬件和软件信息的一种技术。如:CPU 使用率,磁盘使用率,内存使用率,进程情况,线程情况等。

## HTTP 协议处理

使用 Netty 服务开发。实现 HTTP 协议处理逻辑。
