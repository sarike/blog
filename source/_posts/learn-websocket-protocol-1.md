---
title: WebSocket协议（一）- 简介以及连接建立过程
tags:
  - http
  - JavaScript
  - websocket
id: 96
categories:
  - 技术笔记
date: 2015-11-23 00:28:04
---

最近需要做一个即时性较高的web应用，公司内部使用大可以放心使用最前沿的web技术，考虑到Ajax和长轮询的弊端，决定使用H5的新特性WebSocket，保证服务端有数据变化时能立马主动推送给客户端，无需等待客户端请求。

下面咱们由浅入深地一起来学习一下websocket。

### 1\. WebSocket是什么？

WebSocket是HTML5开始提供的一种在单个TCP 连接上进行全双工通讯的协议。WebSocket通讯协议于2011年被IETF定为标准[RFC 6455](https://tools.ietf.org/html/rfc6455)，WebSocketAPI被W3C定为标准。（摘自维基百科）

首先WebSocket是一个协议，只要经过一次握手就可以跟WebSocket服务器建立全双工通信的连接，既然是全双工通信，所以连接建立成功之后，客户端可以向服务器端发送数据，服务端也可以主动向客户端推送数据。

在WebSocket之前，实现实时更新服务器数据的功能都是通过轮询的方式来实现的，这些实现方式有一个共同点，都是由客户端主动向服务器端发起请求，不难想象，轮询的方式就有一个轮询时间间隔的问题，间隔长了服务端的数据不能及时更新到客户端，间隔短了就会有许多无用的请求，增加服务器压力，浪费服务器以及带宽资源，于是大家迫切希望有一种技术能让服务器端有数据的时候主动推送给客户端，OK，WebSocket就是满足这个需求的。

另外，WebSocket是另一个独立的基于TCP协议的通信协议，不是HTTP协议的增强功能，但是也并非与HTTP协议没有什么任何关系，后面会讲到。

<!--more-->

### 2\. WebSocket初体验

刚才说了WebSocket是一种独立的基于TCP的通信协议，那么使用WebSocket就需要有实现了WebSocket协议的服务端，各种语言的实现基本上都能找得到，比如NodeJS实现的[Socket.io](http://socket.io/)，这些库用起来方便，但是由于进行了较高程度的封装，不利于我们学习了解WebSocket的原理，所以本文跟大家一步步通过NodeJS实现一个简单的WebSocket服务端程序，出于学习的目的，代码中没有进行错误处理。

由于本文DEMO代码暂时还未完成，感兴趣的同学可以先体验下Socket.io官方的[聊天室DEMO](http://socket.io/demos/chat/)。

### 3\. 建立TCP连接

WebSocket是基于TCP协议的，所以第一步就是要建立一个TCP连接，关于TCP的知识，本文中就不赘述了，不熟悉的同学可以搜索相关资料或者书籍学习下。这里我们直接用NodeJS的net模块来创建一个TCP服务，监听7002端口。如下代码：

```javascript
//index.js
var net = require('net');

net.createServer(function(socket) {
    console.info('tcp client connected');

    socket.on('data', function(data) {

    }); 

    socket.on('end', function() {
        console.info('client disconnected');
    }); 
}).listen(7002);
```
执行：`node index.js`

在浏览器中执行如下代码：

```javascript
var ws = new WebSocket("ws://localhost:7002");
```

在服务端控制带看到 tcp client connected 的输出，说明已经建立TCP连接。

### 4\. 建立WebSocket连接

建立TCP连接之后，开始建立WebSocket连接，上文说过WebSocket连接只需一次成功握手即可建立。握手过程如下图所示（图片来自互联网）：

{% asset_img ws-shake-hand.png 握手过程 %}

1）首先客户端会发送一个握手包。这里就体现出了WebSocket与Http协议的联系，握手包的报文格式必须符合HTTP报文格式的规范。其中：

* 方法必须位GET方法
* HTTP版本不能低于1.1
* 必须包含Upgrade头部，值必须为websocket
* 必须包含Sec-WebSocket-Key头部，值是一个Base64编码的16字节随机字符串。
* 必须包含Sec-WebSocket-Version头部，值必须为13
* 其他可选首部可以参考：[https://tools.ietf.org/html/rfc6455#section-4.1](https://tools.ietf.org/html/rfc6455#section-4.1)

2）服务端验证客户端的握手包符合规范之后也会发送一个握手包给客户端。格式如下：

* 必须包含Connection头部，值必须为Upgrade
* 必须包含一个Upgrade头部，值必须为websocket
* 必须包含一个Sec-Websocket-Accept头部，值是根据如下规则计算的：

    * 首先将一个固定的字符串258EAFA5-E914-47DA-95CA-C5AB0DC85B11拼接到Sec-WebSocket-Key对应值的后面。
    * 对拼接后的字符串进行一次SHA-1计算
    * 将计算结果进行Base-64编码

3）客户端收到服务端的握手包之后，验证报文格式时候符合规范，以2）中同样的方式计算Sec-WebSocket-Accept并与服务端握手包里的值进行比对。

其中任何一步不通过则不能建立WebSocket连接。

熟悉了这个过程之后呢，我们进一步编写我们的代码，如下所示：

```javascript
//index.js
var net = require('net');
var crypto = require('crypto');

var wsGUID = "258EAFA5-E914-47DA-95CA-C5AB0DC85B11";

net.createServer(function(socket) {
    console.info('tcp client connected');

    socket.on('data', function(data) {
        var dataString = data.toString(),
            key = getWebSocketKey(dataString),
            acceptKey;
        if (key) {
            console.info(key);
            acceptKey = genAcceptKey(key);
            socket.write('HTTP/1.1 101 Switching Protocols\r\n');
            socket.write('Upgrade: websocket\r\n');
            socket.write('Connection: Upgrade\r\n');
            socket.write('Sec-WebSocket-Accept: ' + acceptKey + '\r\n');
            socket.write('\r\n');
        }
    });

    socket.on('end', function() {
        console.info('client disconnected');
    });
}).listen(7002);

function getWebSocketKey(dataStr) {
    var match = dataStr.match(/Sec\-WebSocket\-Key:\s(.+)\r\n/);
    if (match) {
         return match[1];
    }
    return null;
}

function genAcceptKey(webSocketKey) {
    return crypto.createHash('sha1').update(webSocketKey + wsGUID).digest('base64');
}
```

重新运行服务端之后，在浏览器执行如下代码：

```javascript
var ws = new WebSocket("ws://localhost:7002");
ws.onopen = function() {
    console.info('connected');
};
```

在浏览器控制台看到打印出 connected 说明WebSocket连接已经创建成功。

5\. 总结

通过建立连接这个过程，我们可以思考下WebSocket与HTTP服务的关系。WebSocket和HTTP都是基于TCP协议，我们这个Demo出于学习的目的只是实现WebSocket协议，实际应用中WebSocket服务与HTTP服务应该在同一个TCP服务之上，同一个host，同一个port。客户端握手包中的Upgrade头部、以及服务端握手包的101状态码，以及头部结束后要有一个空行，这些都是在HTTP协议中有定义过的:

* Upgrade头部：[https://tools.ietf.org/html/rfc2616#section-14.42](https://tools.ietf.org/html/rfc2616#section-14.42) 客户端希望通过另一种协议进行通信，希望服务端进行协议转换。
* 101状态码：[https://tools.ietf.org/html/rfc2616#section-10.1.2](https://tools.ietf.org/html/rfc2616#section-10.1.2) 服务端理解了客户端的Upgrade头部信息，同意进行协议转换。

所以说HTTP与WebSocket是存在交集的两个不同的协议，正是这部分交集使我们更方便地在Web应用开发中使用它。

WebSocket连接建立成功之后就真跟HTTP协议没有什么关系了，之后的数据传输完全就是WebSocket协议的内容了。

WebSocket的协议文档总共有71页，内容非常多，不可能通过简简单单两篇文章说得面面俱到，有表达的不对的地方，欢迎留言讨论，多谢。
