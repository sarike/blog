---
title: JavaScript简明教程
tags:
  - JavaScript
  - 前端
  - 教程
id: 60
categories:
  - 技术笔记
date: 2015-10-25 17:52:17
---

在公司承诺Q4给部门前端同事进行两次技术分享，原本打算第一次分享一下前端的相关开发工具，详细讲解下Gulp的使用、原理以及插件机制；第二次重点分享一下前端的模块化开发，重点分享一下webpack+ReactJs这一对好搭档。原本想想分享内容满满的逼格，心里还有点小激动，但是最近发现大家JS相关的技术基础都不是很好，所以我意识到即便是逼格再高，大家体会不到这种逼格也是白搭，所以在征求了多位同事的意见之后，决定先培训下Javascript的基础知识。

开始前先来个声明，虽然是Javascript教程，但是个简明教程，所以还是针对有一定编程经验的同学们，也就是说这里肯定不会花半个字符去说if..else是啥意思。本文与其说是个教程，倒更像是对Javascript知识点的一个梳理，希望我的同事们会喜欢，也希望能对互联网上的其他小伙伴们有所帮助。

<!--more-->

## 一、Javascript八卦

Javascript与Java没有半毛钱的关系，Javascript最早由网景公司设计实现，后来微软依托巨大的Windows市场份额霸道捆绑IE浏览器，并推出了JScript并能在IE浏览器中运行，关键时刻总有顾大局者出来主持公道，ECMA感觉这么搞不行，于是联合微软、网景以及其他多家大型公司决定制定一个统一的规范，也就是我们现在所熟知的：ECMA-262，所以Javascript也被成为EcmaScript。

Javascript一直以来只能在浏览器中运行，直到NodeJs的出现，将Javascript带入了服务端开发语言的阵容，而且现在NodeJs真是火的不行不行的，现在没有整过几句NodeJS，都不好意思在前端社区里发言。当然啦，本文还是针对浏览器中的Javascript。

我晕，我发现我废话简直是太多了，说正事儿。

Javascript在浏览器中由三部分组成：

* EcmaScript：这就是上面说的那个标准，它定义了这门语言的语法以及相关的语言特性
* DOM：文档对象模型，Javascript是通过这个来跟HTML文档进行交互的
* BOM：浏览器对象模型，Javascript是通过这个来跟浏览器进行交互的

## 二、Javascript语法（EcmaScript）

### 1\. 变量声明

Javascript是一门弱类型的语言，所谓弱类型就是在声明变量的时候不需要指定变量的类型，一个 var 关键字就够了，甚至连 var 都可以不用，不使用 var 时它就是一个全局变量。

#### 1.1 变量的提升机制

在Javascript中，解释器在执行一个函数时，会先扫描函数体，将所有的变量声明语句提升到函数最开始的地方，变量的赋值原地不动。举个栗子：

```javascript
function foo() {
    console.info(name); //这一句并不会抛出变量未定义的Error
    var name = 'Lucy';
    console.info(name);
}

foo();
// undefined
// Lucy
```

不了解该机制的同学很容易采坑，所以编写Javascript要有个好习惯，将所有的变量声明语句写在函数的最前面。

### 2\. 变量作用域

Javascript中只有两种作用域，一个是全局作用域，一个是函数作用域。

全局变量有三种声明方式：

* 为window对象添加一个新的属性，如：window.name = 'Lucy'，其实window也是window的一个属性，不行你试试window.window;
* 在函数外部声明的变量
* 在任何位置省略掉 var 声明的变量

不管怎么声明的全局变量最终都会被作为一个属性绑定到window上。

局部变量，那就是在函数内部通过 var 声明的变量。

**友情提示：诸多前辈们踩过无数的坑之后告诉我们，尽量不要使用全局变量，除非你明确知道自己在干什么。**

### 3\. 变量类型

Javascript中有六种变量类型：Undefined, Null, Boolean, String, Number, Object。

* Undefined：值为 undefined 的变量（没有赋值的变量的值就是undefined。注意：这里的 undefined 可不是个字符串哟。
* Null：值为 null 的变量
* Boolean：只有 true 和 false
* String：是一个一定长度的有序的UTF-16字符序列
* Number：除了你印象中的所有数字以外还有：NaN（Not-a-Number）、Infinity（无穷大）
* Object：对象就是属性的集合，先这么说吧，具体后边再表。

Undefined，Null，Boolean，String，Number这五种类型（没有Object）的值被称作是原始数值，例如：1，true，null，undefined，'hello Lucy'。

Javascript内置了Boolean，String，Number这三种数据类型的构造器（如果有Java或者PHP等语言经验的同学可以理解位类，实际上是一个 Function），通过 new 关键字可以创建对应原始类型的对象，对象就是对对应原始数值的封装，添加了许多方便使用的成员方法，例如：

```javascript
var name = new String('Lucy');
console.info(name.toUpperCase()); // LUCY
```

其实，在实际的开发中很少会这么用，而是通过直接赋值的方式，一是因为这么书写比较麻烦，二是这样不方便获知变量的真实类型，因为 typeof 都是 'object'，更重要的是直接赋值也可以调用对象的成员方法。

既然说到 typeof 那就一起来聊聊这个玩意儿，typeof 是在javascript中是一个关键字，顾名思义，他是用来判断一个变量的类型，但是实际使用起来却往往跟你想象的不一样。举个栗子：

```javascript
var varStr2 = ''; 
console.info(typeof varStr2); // 'string'

var varStr = new String('');
console.info(typeof varStr); // 'object'

var varNumber = 1;
console.info(typeof varNumber); // 'number'

var varNumber2 = new Number(1);
console.info(typeof varNumber2); // 'object'

var varBoolean = true;
console.info(typeof varBoolean); // 'boolean'

var varBoolean2 = new Boolean(true);
console.info(typeof varBoolean2); // 'object'

var varNull = null;
console.info(typeof varNull); // 'object'

var varUndefined;
console.info(typeof varUndefined); // 'undefined'

var varArray = [];
console.info(typeof varArray); // 'object'

var varArray2 = new Array([]);
console.info(typeof varArray2); // 'object'
```

null竟然是 object？不要问为什么，标准里就是这么规定的。

从上面的例子我们可以看到对于String，Number，Boolean如果我们坚持通过直接赋值的方式来使用，是可以很容易通过typeof来确定它的类型的，但是唯独Array（数组）不行呢，嗨嗨，这是因为Javascript中数组不是一种数据类型，它只是内置的对象罢了，与Date，Math，JSON，RegExp等这些是一样的，只是做了一个语法糖可以通过[]来直接创建一个数组，仅此而已。

那有没有办法判断一个变量是不是数组呢？当然有！上栗子：

```javascript
console.info({}.toString.call([])); // [object Array]
console.info({}.toString.call(new Array([]))); //[object Array]
```

### 4\. 函数

函数也是一个对象，所以可以直接给函数设置属性。但函数是一个可以执行的对象，typeof 一个函数返回的是"function"。

可以将一个匿名函数赋值给一个变量，被赋值为函数的变量名并不是函数名。

非匿名函数可以在作用域范围内的任何位置进行声明和调用，无需先声明后调用；但是如果是通过匿名函数来赋值变量的方法声明函数，必须在变量被成功赋值以后才能通过该变量来调用对应的函数。

函数可以作为函数的参数，函数也可以作为函数的返回值。

即便是函数没有定义形参列表，也可以在调用的时候给函数传递任意多个（标准中没有明确说明函数最多能接受多少个参数，但是不同的浏览器会有一定的限制，但数值也会很大，咱们姑且认为是任意多个）参数，在函数中可以通过 arguments 变量来获取。

即便是函数定义了明确的形参列表，也可以在调用的时候不传递任何参数，或者传递部分参数（按顺序），没有接收到实参的参数的值是 undefined。

#### 4.1 闭包

对于闭包这个概念，可能每个人都有每个人的理解，我的理解很简单，我认为闭包就是函数中定义的函数，哈哈……

在函数作用域内定义一个函数，这样会产生嵌套的函数作用域，内部函数作用域可以访问祖先函数作用域的局部变量，反过来却不行，由于这个特性闭包经常用来隐藏内部变量的作用，实现private的效果，栗子：

```javascript
function Counter(start) {
    var c = start || 0;
    return {
        inc: function () {
            return ++c;
        }
    }
}

var c1 = new Counter();
c1.inc(); // 1
c1.inc(); // 2

var c2 = new Counter(5);
c2.inc(); // 6
c2.inc(); // 7
```

#### **4.2 this**

好多人感觉Javascript中的this是很诡异的一个东西，但是仔细想想，它跟其它面向对象的开发语言中的this差别没有那么大，都是指向调用该函数的那个对象，这个对象也称作是函数的上下文（Context）。只不过在Javascript中，一个函数中所使用的this是不确定的。

直接执行一个已经定义的函数，函数内部的this就是指全局对象window。

如果是通过一个对象来调用一个函数，那这个函数内部的this就是指向调用该函数的对象。

可以通过函数的 call 或者 apply 方法来改变函数的上下文，只是二者在接收函数参数时有所不同，call需要手动将函数要接收的参数依次传入，而apply可以将函数要接收的参数以数组的形式传入。栗子：

```javascript
var name = 'global';

var contextObj = {};

function foo(name) {
    this.name = name;
}

foo("Lucy");
console.info(window.name); // Lucy

foo.call(contextObj, "Tom");
console.info(contextObj.name); // Tom

foo.apply(contextObj, ["Jack"]);
console.info(contextObj.name); // Jack
```

但是，call和apply会立即执行当前函数，那可不可以先指定函数的上下文，之后再执行该函数呢？当然可以，在ES5中新添加了一个方法叫做bind，上栗子：

```javascript
var contextObj = {};

function foo(name) {
    this.name = name;
}

var newFoo = foo.bind(contextObj, "Lucy");
newFoo();

console.info(contextObj.name);
```

#### 4.3 原型 prototype

在ES5及之前的Javascript规范中是没有class（类）机制的，属性的共享就是通过Javascript独有的原型链的方式来实现的。ES6中添加了类机制，但本质上还是操作的原型链（个人感觉，没有深入求证）。

prototype是函数的属性，而不是对象的属性。（我知道函数也是一个对象，但我相信你明白我的意思）

一个函数的prototype属性，必须是一个对象，当用该函数通过new关键字创建一个对象的时候，prototype的属性及方法都可以通过这个新的对象来访问，这样就起到了属性共享的作用。

很容易想到，函数的prototype对象也存在原型对象，这样就形成了一条原型链，当我们访问一个对象的某个属性或者方法时，Javascript引擎会沿着原型链一直往上找，找到则终止查找返回对应的值，如果找到头（原型对象为null）时还没有找到，则返回undefined。

ES5中新增了一个方法，Object.create()，可以用来创建一个新的对象，新对象的原型就是create方法的第一个参数。栗子：

```javascript
var a = {a: 1}; 
// a ---> Object.prototype ---> null

var b = Object.create(a);
// b ---> a ---> Object.prototype ---> null
console.log(b.a); // 1 (继承而来)
```

#### 4.4 函数的重载

熟悉Java等其他面向对象语言的同学，对方法的重载一定不陌生，相同的方法名，通过设置不同的参数列表，可以执行不同的方法体。可惜Javascript不行。

前面已经说过了，不管Javascript的函数定义了或者没有定义参数列表，你都可以在调用时传入任意多个任意类型实参，Javascript怎么能根绝参数列表来实现重载呢，其实利用Javascript这一点反倒能实现类似函数重载的效果，上栗子：

```javascript
function foo(name, age, callback) {
    if (arguments.length === 3) {
        console.info('do something with name, age and a callback function');
    } else if (arguments.length === 2 &amp;&amp; typeof age === 'function') {
        console.info('do something with name and a callback function');
    } else {
        throw new Error('method not defined');
    }
}

foo('Lucy', 23, function() {}); // do something with name, age and a callback function
foo('Lucy', function() {}); // do something with name and a callback function
foo(); //Error
```

Javascript语法部分感觉有必要说的貌似就这么多，如果再想起点别的来，再补充。

## 三、文档对象模型（DOM）

关于Dom，只讲解下Dom的事件，关于Dom节点的查找，原生的API实在是没有必要说了，大家都用JQuery，我也比较务实，人生苦短嘛。

为什么要说一下Dom的事件呢，Javascript运行在浏览器中最主要的任务就是增强网页与用户之间的交互性，而用户与页面之间进行交互的桥梁，就是事件。

经常有同事跟我说，用Javascript频繁改动页面DOM结构的时候，还要同步更新他们的事件绑定，好烦呀。呵呵……这就是对DOM的事件机制不熟悉的表现。

先上张图：（图片来自 http://www.w3.org/TR/uievents/#event-flow）

{% asset_img eventflow.png event flow%}

图片描述了DOM的事件流，当用户触发一个事件时，浏览器会创建一个Event对象，该事件对象会从window开始，依次经过事件目标的所有祖先节点，如图中红线所示，此阶段称作事件的捕获阶段，当事件传播到达事件目标节点时，进入目标阶段，图中蓝色字体所示；目标阶段之后，会沿与捕获阶段相反的方向将事件对象传播回window，此阶段称作为冒泡阶段。

在事件传播的过程中，可以通过时间的eventPhase属性来判断当前时间处于什么阶段，属性的值1、2、3分别代表捕获阶段、目标阶段、冒泡阶段，当整个事件流结束之后，eventPhase的值会被设置为0；

父节点默认是在冒泡阶段接收到事件时触发事件处理函数的，可以将addEventListener的第三个参数设置为true让它在捕获阶段触发。

事件处理函数触发时我们最关心的是获取触发事件的那个DOM节点，以进行后续操作，事件对象有这两个相关属性：currentTarget和target，targe就是触发事件的那个DOM对象，也就是目标阶段最深到达的节点，该属性在事件的传播过程中一直保持不变；currentTarget是会跟随时间的传播动态变化的，事件对象传播到哪个节点，它的值就是哪个DOM节点，当整个事件流结束以后，currentTarget的值会被设置为null；

明白了这个过程之后，处理页面上的事件交互就会得心应手了，当页面上某个区域的Dom节点频繁变化时，只需要在其某个祖先节点（例如body）进行一次事件处理函数的绑定即可。例如在JQuery中：

```javascript
$('body').on('click', '#some-button', function(e) {
    var target = $(e.target);
    // do something
});
```

需要注意的是，JQuery中的事件对象是JQuery自己的，并不是原生的W3C规范里说的那个，你可以通过JQuery事件对象的originalEvent属性获取原生的事件对象，而且JQuery事件对象的currentTarget属性与原生事件对象的currentTarget的行为不一致，JQuery事件对象中的currentTarget不会随着事件流的传播而变化，而是一直与 target 保持一致，而且在事件流结束以后不会被设置为null，eventPhase也不会被设置为0；不知道是JQuery的BUG还是有意为之，不过大部分场景只需要一个e.target或者this就足够了。

## 四、浏览器对象模型（BOM）

浏览器对象模型，这个东西感觉没有多少有必要说的，想起来再说

## 五、相关资料

http://es5.github.io/

http://www.w3.org/TR/uievents/

https://developer.mozilla.org/zh-CN/docs/Web/JavaScript
