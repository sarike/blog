---
title: 基于流的构建工具 - Gulp
tags:
  - gulp
  - JavaScript
  - NodeJS
  - 前端
id: 72
categories:
  - 技术笔记
date: 2015-10-31 19:29:46
---

自从NodeJS面世以后，前端的各种各样的开发工具真的是如雨后春笋般层出不穷，脑洞开了真是挡都挡不住。

今天咱们来聊一聊目前非常流行火爆（Github将近2万Star）的一款前端神器：[**Gulp**](https://github.com/gulpjs/gulp)，如果让我用一句话来评价它，那就是：简单又足够强大。简单得让你看几眼Readme就能够上手使用，强大得让你想不到有什么前端构建的工作它是办不到的，关键是性能卓越。当然啦，Gulp的强大离不开它的插件机制以及社区的贡献。

Gulp官网：[http://gulpjs.com](http://gulpjs.com/)

Github：[https://github.com/gulpjs/gulp](https://github.com/gulpjs/gulp)

继续往下看之前，你可以先浏览下官方的文档，或许下面的文章都没有必要看下去了。

<!--more-->

## 一、Gulp简介

Gulp是一个流式的构建系统。

构建，什么是构建？其实很简单，构建就是读取源文件、处理文件、生成目标文件的一个过程。

所有的构建工具都在努力地帮助开发者更顺利地完成这个过程，差别在于谁能让这个过程执行起来更简单、更高效。

Gulp做到了，而且 [Gulp的目标是取代Grunt](http://www.infoq.com/cn/news/2014/02/gulp)，作为一个前端开发者即便没用过你一定听说过Grunt，基本上所有流行的前端库中都有一个Gruntfile.js文件，然而现在，World is changing...

什么是流式的？流式就像是将一个个文件处理过程用管子连接起来形成一条没有岔路口的管道，文件内容通过入口流入管道（读取源文件），经过一系列的处理之后从出口流出（生成目标文件）。

整个流式的处理过程中，不会有中间文件的产出，减少了不必要的IO操作，所以Gulp是非常高效的。

注意：

1. Gulp是通过NodeJS来开发的，Gulp本身以及它的所有插件都是通过npm来安装的，所以文章后面的内容都认为你已经安装好了NodeJS以及npm，如果没有的话你可以去 [NodeJS官网](https://nodejs.org) 把NodeJS下载并安装一下。

2.  写该文章时，Gulp的最新版本是3.9.0

## 二、入门手册

### 1\. 安装

首先要全局安装Gulp，这是为了全局使用gulp命令。

```shell
$ npm install --global gulp
```

然后，作为当前项目的依赖安装Gulp，这是为了在Gulp的配置文件中使用Gulp提供的API。

```shell
$ npm install --save-dev gulp
```

Gulp是通过执行gulp命令来使用的。你可以执行下 gulp -v，如果之前安装成功的话，控制台会打印出全局Gulp与本地Gulp的版本，如：

### 2\. gulpfile.js和任务

使用Gulp，必须通过一个构建文件（或者说配置文件）来预先设定好构建工作如何进行，默认的构建文件是当前目录下的gulpfile.js，你也可以在执行gulp命令时通过 `--gulpfile` 参数来指定。Gulp是通过NodeJS开发的，所以gulpfile.js也会当做NodeJS的模块来执行，所以你可以在gulpfile.js里引入并使用所有的NodeJS内置模块以及NPM安装的模块。

使用Gulp进行的所有构建工作是通过一个个任务来完成的。

下面是一个最基本的gulpfile.js，设定了一个名称为'default'的任务。

```javascript
var gulp = require('gulp');

gulp.task('default', function() {
    console.info('Hello Gulp!');
});
```

在当前目录下执行 gulp 命令，控制台会输出任务的开始时间、结束时间以及整个任务所消耗的时间还有任务执行过程中的控制台输出，如果你只想看任务的输出，你可以在执行 gulp 命令的时候指定 `--silent` 参数让她保持安静。另外默认情况下控制台输出的不同内容是有不同颜色高亮的，你可以通过指定 `--no-color` 来拒绝五颜六色。

如上面的例子所示，当只执行 gulp 命令的时候，默认会执行 'default' 任务，如果没有定义 default 任务，Gulp会报错，你可以尝试一下。你可以如下所示运行某个或某些特定的任务：

```shell
gulp [task1] [task2] [task3] ....
```

### 3\. Gulp的API

Gulp需要学习的API只有四个！要么咋说Gulp简单呢。

#### 3.1 一个正式点儿的例子

下面一个稍微复杂点的gulpfile.js的实例，其中用到了Gulp的所有API，并且示范了一个比较完善的构建CSS代码的任务：

```javascript
var gulp = require('gulp');
var less = require('gulp-less');
var minifyCss = require('gulp-minify-css');
var concat = require('gulp-concat');

gulp.task('build_css', function() {
    gulp.src('styles/*.less')
        .pipe(less())
        .pipe(concat('main.css'))
        .pipe(minifyCss())
        .pipe(gulp.dest('dist/style/'));
});

gulp.task('default', function() {
    gulp.watch('styles/*.less', ['build_css']);
});
```

这里定义了一个名为 build_css 的任务，该任务将 styles目录下的所有 .less 文件编译成css文件，然后合并成一个main.css文件并进行压缩，最后将文件输出到 dist/style 目录下。

默认的 default 任务创建里一个监听器，他会一直监听 stype 目录下所有 .less 文件的变化，只要文件一有改动就立马执行 build_css 任务。

可以看到其中用到了：gulp.task，gulp.src，gulp.dest，gulp.watch 这四个API，也是仅有的四个。

#### 3.2 globs

glob这个词在阅读Gulp的API文档时经常会遇到，在这里跟大家解释一下。

Gulp的每个构建过程开始时都需要读取一些文件，有时文件非常多，不可能将每个文件都明确指定，而且在开发过程中源代码文件会不断增多，而gulpfile.js可能只需编写一次，所以需要一种方式来指定批量的文件。**glob就是这样一种通过通配符来批量指定文件路径的字符串表达式**。例如：`./**/*.js`   可以匹配当前目录以及所有子目录中的javascript文件。

glob的语法非常简单，可以看下：[https://github.com/isaacs/node-glob#glob-primer](https://github.com/isaacs/node-glob#glob-primer)

glob并不是Gulp首创的，实际上我们在linux中指定文件路径时就是通过glob来通配文件的。

#### 3.3 四个API

对于Gulp的四个API详细的使用方法，我就没有必要把官方文档再翻译一遍了。下面是地址，自己看看吧：

[https://github.com/gulpjs/gulp/blob/master/docs/API.md](https://github.com/gulpjs/gulp/blob/master/docs/API.md)  （[中文版本](http://www.gulpjs.com.cn/docs/api/)）

下面只说一些与这四个API有关的、文档里可能没有的、文档里有但需要进一步解释的内容：

**gulp.task**

创建一个任务，任务名不能有空格。

创建任务时可以通过第二个参数以**数组的形式** 设置当前任务依赖的任务，只有当依赖的任务执行完以后当前任务才能执行。

异步任务，大家在Gulp的文档中很容易看到这个词，这个异步也就是NodeJS中说的异步，自从走上前端开发这条路，感觉与多线程这个概念渐行渐远了，但个人觉得好多人对于NodeJS中的异步有些迷惑甚至是误解，就是Javascript不管在浏览器还是NodeJS上都是单线程运行的，为什么会有异步这个概念呢。实际上Javascript代码确实是在单一的主线程中运行的，但是NodeJS和浏览器是有线程调度能力的。这个不是本文关注的问题，感兴趣的同学可以参考本文后面的参考资料中的几篇相关文章，问题回到Gulp的异步任务，并不是说gulp.task的回调函数中的代码都是在一个新的线程中执行的，而是说I/O，也就是读取、写入文件等过程是异步的。

**gulp.src**

读取要构建的源文件，可以接收第二个参数 options 来指定一些额外的选项，这个参数会通过 [glob-stream](https://github.com/gulpjs/glob-stream) 传递给 [node-glob](https://github.com/isaacs/node-glob) ，所以 options 可以指定glob-steam和node-glob支持的选项，除此之外Gulp提供了3个自己的选项：buffer、read、base，这里我们只说一下个人对base这个选项的理解。

base不会改变搜索源文件的路径，却会影响文件输出的路径，默认base的值值通过 [glob2base](https://github.com/contra/glob2base) 这个模块来解析得到的，大体描述就是：base是一个glob中通配符之前的部分，如果是文件路径，则为目录部分。

大家可以看下Gulp文档中的实例代码，感受一下：

```javascript
gulp.src('client/js/**/*.js') // Matches 'client/js/somedir/somefile.js' and resolves `base` to `client/js/`
  .pipe(minify())
  .pipe(gulp.dest('build'));  // Writes 'build/somedir/somefile.js'

gulp.src('client/js/**/*.js', { base: 'client' })
  .pipe(minify())
  .pipe(gulp.dest('build'));  // Writes 'build/js/somedir/somefile.js'
```

gulp.dest，和 gulp.watch 没啥好说的，大家看文档就好。

## 三、总结

简单总结一下，学习Gulp，其实只需要知道一下几件事情就足够了：

* Gulp是一个构建系统，能够以一种高效的方式帮我们将一些源代码文件处理成另外一些我们想要的或者说更适合线上产品使用的文件。
* Gulp是通过执行一些预先定义好的任务来完成构建工作的，任务之间还可以设置依赖。
* Gulp可以监听文件的变化，文件改动之后会立马有任务进行响应。
* Gulp有四个简单的API来实现上面的事情，它们是这样这样这样来用的。
* Gulp有强大的插件机制，插件可以帮助我们完成各种各样的文件处理工作，插件可以在npmjs.org中搜索得到，通过npm安装后即可使用。

另外，走马观花浏览了下Gulp的代码，Gulp的核心功能是通过下面几个模块来协作完成的，希望对感兴趣的同学有所帮助。

1.  Gulp的流是通过[vinyl-fs](https://github.com/gulpjs/vinyl-fs) -> [glob-stream](https://github.com/gulpjs/glob-stream) -> [through2](https://github.com/rvagg/through2) 对NodeJS的内置Stream进行封装之后的流。

2.  Gulp的任务依赖的处理以及执行都是是通过 [Orchestrator](https://github.com/orchestrator/orchestrator)  来完成的，其中处理任务依赖是通过[sequencify](https://github.com/robrich/sequencify) 这个小模块来获取任务执行的先后顺序的。

原本计划一起说一下Gulp的插件开发，由于时间的原因，下一篇文章单独来说一下Gulp的插件开发。

## 五、相关资料

1. [http://slides.com/contra/gulp](http://slides.com/contra/gulp) Gulp的核心作者早期对Gulp的介绍以及与Grunt的对比，足以看出Gulp是为了干掉Grunt而生的。

2. [https://github.com/substack/stream-handbook](https://github.com/substack/stream-handbook) NodeJS stream手册，介绍了如何在NodeJS中进行流编程。

3. [http://codedocker.com/transon-problems-with-threads-in-node-js/ ](http://codedocker.com/transon-problems-with-threads-in-node-js/)NodeJs中多线程的问题，单元能让你对Gulp的异步任务的理解有所帮助

