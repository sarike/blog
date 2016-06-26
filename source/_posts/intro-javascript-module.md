---
title: Javascript的模块化开发 - AMD
tags:
  - JavaScript
  - RequireJs
  - 前端
  - 模块化
id: 81
categories:
  - 技术笔记
date: 2015-11-09 23:45:57
---

现在聊Javascript的模块化开发已经不是什么新鲜话题了，ES6都已经发布了，原生的模块化支持也即将到来，然而主流浏览器将规范实现到能用在生产环境还是有一定的时间，了解并学习当前流行的Javascript模块化开发技术还是非常有必要的，从传统的前端开发方式转换到模块化开发，绝对会让你感觉Web前端开发进入了一个新的阶段。

我最早接触模块化开发是第一次参加工作的时候，真的很庆幸刚参加工作就能遇到一个不守旧且靠谱的团队，当时用的是支付宝团队开发的[Seajs](http://seajs.org/docs/)，接手项目一段时间后真的曾在心里不由得感慨过：原来JS还可以这么玩。

下面推荐两篇Seajs的作者玉伯写的两篇文章：

1. [前端模块化开发的价值](https://github.com/seajs/seajs/issues/547) 描述了传统的开发方式存在的问题以及为什么要进行前端模块化开发。

2. [前端模块化开发那点历史](https://github.com/seajs/seajs/issues/588) 描述了流行的模块化规范的发展历史，很有意思。

<!--more-->

毕竟是Seajs的作者，文章内容很多是关于Seajs相关的，但其实大部分内容是普适所有模块化加载器的。而且我现在在项目中已经不再使用Seajs了，主要是因为当年的SPM，实在是不太适合我的开发习惯，当然，可能是当时spm3.x刚出来，还有许多不完善的地方，这么久了没关注今天瞅了下社区，感觉还是蛮活跃的，衷心地祝福她。

今天要聊的主要内容是AMD和RequireJs。

### 1\. AMD模块的定义

AMD是规范，[RequireJs](http://requirejs.org/)是对AMD规范的实践，AMD的全称是Asynchronous Module Definition（异步的模块定义），一说到异步，大家果断就想到了回调，没错，AMD的模块就是这么定义并且被加载的，如下代码：

```javascript
//下面定义一个名称为 main 的，依赖 jquery 的AMD模块
define('main', ['jquery'], funcion($) {
    //此时当前模块的所有依赖已经加载并执行完毕
    return {};
});

//下面加载main模块
require('main', function(main) {
    // do something with main
});
```

在AMD的规范中，貌似就这两个API，通过 define 方法来定义一个模块，通过 require 加载一个模块。上边第一段代码是定义一个模块的一种方式，此时define接受三个参数：

1.  模块的名称（可以省略），在实际开发中，这个参数通常省略，因为模块名会被解析成路径来加载目标模块，省略模块名就省去了代码结构调整时需要同步调整模块名的麻烦。另外，处于性能考虑，在产品上线时会将模块文件通过RequireJs的优化工具r.js进行代码的合并压缩，此时r.js会自动根据路径将该参数补充完整。

2.  模块的依赖（可以省略），特别注意次参数**必须是字符串的数组（即便只依赖一个模块），且不能包含变量**。这是因为Javascript是一门脚本语言，只有在运行时才能知道变量的值，RequireJs是通过对静态代码的解析获取模块依赖的。

3.  模块的工厂函数，该函数的参数按顺序的依赖的模块，返回值就是该模块暴漏出去的内容。
既然模块最终暴露的内容是模块工厂函数的返回值，那也就是说在获取到模块内容之前需要先执行这个工厂函数，这样我们就可以在函数执行的过程中做一些额外的工作，例如对某些类进行实例化等等；另外通过这种方式定义模块可以通过工厂函数的参数依次接收所以来的模块，这是通过函数来定义模块的好处。

如果没有任何需要额外处理的工作，也不依赖其他的模块，你可以直接通过一个对象来定义模块，如下所示：

```javascript
define({
    color: "black",
    size: "unisize"
});
```

### 2\. 同步编码异步加载

模块异步加载在性能方面有它的好处，但是通过这种方式定义模块有一个很恶心的地方，当依赖特别多的时候，就成了下面这个样子：

```javascript
define([ "require", "jquery", "blade/object", "blade/fn", "rdapi",
         "oauth", "blade/jig", "blade/url", "dispatch", "accounts",
         "storage", "services", "widgets/AccountPanel", "widgets/TabButton",
         "widgets/AddAccount", "less", "osTheme", "jquery-ui-1.8.7.min",
         "jquery.textOverflow"],
function (require, $, object, fn, rdapi, 
	oauth, jig, url, dispatch, accounts, 
	storage, services, AccountPanel, TabButton, 
	AddAccount, less, osTheme) {

});
```
产品的用户体验固然重要，但作为一名程序员，为自己争取点开发体验也是应该的，熟悉NodeJS的同学或许知道NodeJS是对CommonJS模块化规范的实践，人家是这样来使用依赖的：

```javascript
var fs = require('fs');
fs.readFile(...);

var _ = require('underscore');
_.each(...);

var xxx = require('xxx');
xxx.doSomething();
```

这种同步加载的方式写起代码来是不是更爽一些？恩，RequireJs的作者也是这么认为的，所以在RequireJs中加了点[糖](http://requirejs.org/docs/whyamd.html#sugar)，使用RequireJs时你也可以这么写：
```javascript
define(function (require) {
    var dependency1 = require('dependency1'),
        dependency2 = require('dependency2');

    return function () {};
});
```
但AMD毕竟是异步的，在执行时RequireJs会将上面这种形式的代码转换成如下形式：
```javascript
define(['require', 'dependency1', 'dependency2'], function (require) {
    var dependency1 = require('dependency1'),
        dependency2 = require('dependency2');

    return function () {};
});
```
嘿嘿，这下你总算是放心了吧。但是请注意，这个转换过程是通过解析模块工厂函数的代码（通过Function.prototype.toString获得）来实现的，是比较耗时的，不应该应用到生产环境中，所以部署之前需要通过r.js进行优化打包，将这个过程提前完成。

既然模块最终暴露的内容是模块工厂函数的返回值，那也就是说在获取到模块内容之前需要先执行这个工厂函数，这样我们就可以在函数执行的过程中做一些额外的工作，例如对某些类进行实例化等等，这是通过函数来定义模块的一个好处。

### 3\. 工厂函数何时执行

上面提到过，通过函数定义模块时可以在工厂函数执行时做一些额外的工作。

细心的同学可能会问，那这个工厂函数在什么时机执行呢？这个问题问的很好，只有清楚了工厂函数是在何时执行的，我们才能更好地利用她，上代码，一目了然：
```javascript
//main.js
define(function(require) {
   console.info('module main executed'); 
   return {
        init: function() {
            console.info('module main inited');    
        },  
        helloA: function(){
            require(['a'], function(a){
                a.init();
            }); 
        },  
        helloB: function() {
            var b = require('b'); 
            b.init();
        }   
   }   
});
```

```javascript
// a.js，b.js跟这个一样就是log不同
define(function() {
    console.info('module a executed');
    return {
        init: function(){
            console.info('module a inited');
        }   
    }   
});
```

```javascript
//index.html
<script src="require.js"></script>
<script>        
    require(['main'], function(main) {
        main.init();          
    });
</script>;
```

结果：
{% asset_img images/result-2.png 运行结果%}


这个结果会让你出乎意料吗？为什么在main.js中既依赖了a.js，又依赖了b.js，却只执行了b.js的工厂函数呢？

根据之前提到的，`var b = require('b');`  这种加载依赖的书写方式会被RequireJs通过解析源码的方式转换成依赖数组的形式。当加载一个模块（main.js）的时候，其依赖数组里的模块必须加载并执行完毕，模块输出的内容作为参数按照顺序传递给该模块（main.js）的工厂函数。a.js没有加载执行，这是RequireJs 2.0版本的新特性，相同的代码放到RequireJs 1.x版本中，结果就会跟 b.js 一样了。具体可以参考如下几个链接：

[https://github.com/jrburke/requirejs/wiki/Upgrading-to-RequireJS-2.0#delayed](https://github.com/jrburke/requirejs/wiki/Upgrading-to-RequireJS-2.0#delayed)
[https://github.com/jrburke/requirejs/issues/183](https://github.com/jrburke/requirejs/issues/183)
[https://github.com/ecomfe/esl/issues/20](https://github.com/ecomfe/esl/issues/20)

### 4\. 局部require与全局require

还是上面的代码，如果我们吧main.js模块的工厂函数的require形参去掉，结果会是怎样呢?

结果如下：

{% asset_img images/result-1.png 运行结果 %}

这时候为什么没有加载并执行b.js呢？不说RequireJs的实现机制，单就Javascript语法来说，相对于之前的代码，之前的require变量是工厂函数的形参，是局部变量，此时require变量变成了全局变量。

其实这里如果调用mian.helloB(); 代码是会报错的，因为`var b = require('b');` 这种加载模块的方式是RequireJs实现的一个语法糖，只有在存在局部的 require 时才会起作用，而全局的 require 加载的依赖必须是一个数组，所以就报错喽。

还有一个问题，我想在定义模块的时候既想设置依赖数组，又想通过局部的require加载其他依赖，那该怎么办呢？其实，局部的require是RequireJs一个内置的模块，模块名为“require”，遇到这种情况时，只需将 require 也作为模块的一个依赖就可以了，例如：

```javascript
define(['require', 'jquery', 'backbone'], function(require, $, Backbone){
    return {
        hello: function() {
            var b = require('b');
            b.doSomeThing();
        }
    }
});
```
