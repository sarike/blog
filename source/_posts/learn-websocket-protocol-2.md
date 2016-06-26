---
title: WebSocket协议（二）- 数据帧格式以及服务端数据推送
tags:
  - NodeJS
  - websocket
id: 111
categories:
  - 技术笔记
date: 2015-12-27 12:28:56
---

唉，长叹一声以表达对我自己深深的鄙视，好多周没有写文章了，实在惭愧，最近公司的工作比较忙（我承认这只是借口），前几天同学问我借钱，竟然还鄙视我，不能忍呀。

今天接上篇继续说WebSocket协议，上篇文章《[WebSocket协议（一）- 简介以及连接建立过程](http://www.timefly.cn/learn-websocket-protocol-1/)》讲解了Websocket通过一次握手建立连接的过程，建立连接后就该传输数据了，这是最核心也是比较复杂的部分，但也非常有意思。

### **一、数据帧（Data Framing）**

WebSocket协议中，数据是通过数据帧来传递的，协议规定了数据帧的格式，服务端要想给客户端推送数据，必须将要推送的数据组装成一个数据帧，这样客户端才能接收到正确的数据；同样，服务端接收到客户端发送的数据时，必须按照帧的格式来解包，才能真确获取客户端发来的数据。

[RFC文档](https://tools.ietf.org/html/rfc6455#section-5.2)中对帧的格式定义如下所示：

{% asset_img ws-data-frame-format.png 数据帧格式%}

乍一看乱七八糟的，看这种东西尤其对前端同学来说，特别晦涩，看到这个东西很容易联想到，大学计算机网络中讲到的TCP/IP协议报文格式，毕竟咱也是科班出身的，下面听我细细道来。

<!--more-->

最上方的第二排数字，每个数字表示一个bit位，这个可以用来确定数据帧格式的每一部分占用的bit位数。

**1\. FIN**

1个bit位，用来标记当前数据帧是不是最后一个数据帧，因为一个消息可能会分成多个数据帧来传递，当然，如果只需要一个数据帧的话，第一个数据帧也就是最后一个。

**2. RSV1, RSV2, RSV3**

这三个，各占用一个bit位，根据RFC的介绍，这三个bit位是用做扩展用途，没有这个需求的话设置位0。

**3. Opcode**

故名思议，操作码，占用4个bit位，也就是一个16进制数，它用来描述要传递的数据是什么或者用来干嘛的，只能为下面这些值：

0x0 denotes a continuation frame 标示当前数据帧为分片的数据帧，也就是当一个消息需要分成多个数据帧来传送的时候，需要将opcode设置位0x0。

0x1 denotes a text frame 标示当前数据帧传递的内容是文本

0x2 denotes a binary frame 标示当前数据帧传递的是二进制内容，不要转换成字符串

0x8 denotes a connection close 标示请求关闭连接

0x9 denotes a ping 标示Ping请求

0xA denotes a pong 标示Pong数据包，当收到Ping请求时自动给回一个Pong

目前协议中就规定了这么多，0x3~0x7以及0xB~0xF都是预留作为其它用途的。

**4\. MASK**

占用一个bit位，标示数据有没有使用掩码，RFC中有说明，服务端发送给客户端的数据帧**不能使用**掩码，客户端发送给服务端的数据帧**必须使用**掩码。

如果一个帧的数据使用了掩码，那么在Maksing-key部分必须是一个32个bit位的掩码，用来给服务端解码数据。

**5\. Payload len**

数据的长度，默认位7个bit位。

如果数据的长度小于125个字节（注意：是字节）则用默认的7个bit来标示数据的长度。

如果数据的长度为126个字节，则用后面相邻的2个字节来保存一个16bit位的无符号整数作为数据的长度。

如果数据的长度大于126个字节，则用后面相邻的8个字节来保存一个64bit位的无符号整数作为数据的长度。

**6. Masking-key**

数据掩码，如果MASK设置位0，则该部分可以省略，如果MASK设置位1，怎Masking-key位一个32位的掩码。用来解码客户端发送给服务端的数据帧。

**7. Payload data**

该部分，也是最后一部分，是帧真正要发送的数据，可以是任意长度。

### **二、组装数据帧**

明白了数据帧的格式以及各个部分的意义后，我们就可以来实际组装一个数据帧了。

具体的代码参考[次碳酸钴](https://www.web-tinker.com/article/20307.html)同学的代码，大部分是移位操作和二进制的加法、与运算，只要记得代码里写的一个10进制的数字是一个字节，会占用8个bit位，一个16进制的数是4个bit位，然后结合上面对帧格式的解释，仔细看下代码应该是很好理解的，如果有什么疑问可以留言：

```javascript
function encodeDataFrame(e){
     var s = [],
         o = new Buffer(e.PayloadData),
         l = o.length;
     //输入第一个字节
     s.push((e.FIN&lt;&lt;7)+e.Opcode);
     //输入第二个字节，判断它的长度并放入相应的后续长度消息
     //永远不使用掩码
     if(l < 126)
         s.push(l);
     else if(l < 0x10000)
         s.push(126,(l&0xFF00)>>8,l&0xFF);
     else 
        s.push(
            127, // 01111111
            0,0,0,0, //8字节数据，前4字节一般没用留空
            (l&0xFF000000)>>24,
            (l&0xFF0000)>>16,
            (l&0xFF00)>>8,
            l&0xFF
        );
     //返回头部分和数据部分的合并缓冲区
     return Buffer.concat([new Buffer(s),o]);
};
```

### **三、推送数据**

数据帧组装完成后，我们就可以将这个帧通过建立好的TCP连接发送给客户端（浏览器）了，如下代码简单演示了，实时将服务器时间以及客户端在线时间实时推送给浏览器，并展示到页面上。

注意喽：

```javascript
//timer，clients是全局变量
//服务端代码添加如下函数
function startPushData() {
    var data,
        startTime = Date.now();
    if (timer || clients.length === 0) return;
    timer = setInterval(function() {
    clients.forEach(function(client) {
            data = {
                startTime: client.startTime,
                currentTime: Date.now()
            };
            client.socket.write(encodeDataFrame({
                FIN: 1,
                Opcode: 1,
                PayloadData: JSON.stringify(data)
            }));
        });
    }, 100);
}

//在每次握手成功后添加如下代码
clients.push({
    startTime: Date.now(),
    socket: socket
});
startPushData();
```

修改浏览器端的网页代码如下：

```html
<div>
     在线时间 : <span id="online-time"></span>
</div>
<div>
     当前服务器时间 : <span id="server-time"></span>
</div>
```


```html
<script>
    var ws = new WebSocket("ws://localhost:7002");
    ws.onopen = function() {
        console.info('connected');
    }; 
    ws.onmessage = function(e) {
        var data = JSON.parse(e.data),
            startTime = data.startTime,
            currentTime = data.currentTime;
        document.getElementById('online-time').innerHTML = (currentTime - startTime)/1000 + 's';
        document.getElementById('server-time').innerHTML = new Date(currentTime);
    }
</script>
```

刷新前端页面就可以看到在页面上展示当前用户与服务端建立链接的时间以及当前的服务端时间，而且打开控制台查看WS连接，可以看到服务端不停地推送过来的数据帧，如下图所示：

{% asset_img frames.jpg 数据帧%}

