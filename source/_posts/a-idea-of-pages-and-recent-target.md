---
title: 一个想法和几个新的技术学习目标
tags:
  - Flux
  - idea
  - ReactJs
  - webpack
id: 90
categories:
  - 一些想法
date: 2015-11-15 21:27:26
---

这次的文章不聊具体的技术了，在公司一直有个想法，而且也是决心要做的，写出来，一来用文字梳理下，二来希望看到的朋友给参谋下靠不靠谱；然后是为了实现这个想法，最近在学习或者将要学习的一些内容，在技术上我不喜欢守旧，即便旧的东西也能用，但是仅仅能用满足不了我，我希望能用而且用起来感觉很酷。

## 一、一个新系统 - Pages

我所在的部门没有具体业务上的压力，我们部门做的都是公司的基础平台，比如监控系统、日志系统、上线系统、项目管理系统等等，我们工作就是让其他部门能够更专注于自己的业务。我的这个想法也是一个内部的基础系统，而且是内部系统他妈，我在心里称之为“内部前端终结者”，当然我是一个内心高调，表面却低调的人，系统上线后我希望他叫“Pages”，更低调也更接地气，有木有，本文后面都使用“Pages”来表示该系统。不兜弯子了，这个号称“内部前端终结者”的系统到底有什么功能。简单概括就是：只要有API，前端页面统统由系统来帮你完成。

<!--more-->

为什么要做这样一个东西呢？有以下几点理由：

1.  基本上各个线上产品都会有各种各样的信息管理系统，所以说市场肯定是有的。
2.  公司前端开发人员技术水平参差不一，各内部系统风格各异、眼花缭乱，时间久了难以维护，Pages能屏蔽前端技术差异，减少部门维护成本，统一内部系统的风格。
3.  省去了内部系统的前端开发人力，这得为公司省多少钱。
4.  能促进内部工具的产生和推广。其实公司里有好多熟悉底层开发的同事针对底层服务有很多实用的API接口，却因为没有一个页面能使其得到很好的推广，如果能让开发前端页面变得非常容易，相信一定会有很多实用的工具页面得到良好的推广，从而帮助员工提高工作效率。
5.  感觉这将会是一个很酷的项目。

## 二、核心功能梳理

### 1\. 项目 - Project

项目就是我们通俗理解的项目，它包含一个或多个页面。

项目可以设置访问权限：公开、用户中心登录、指定人员。

项目可以设置唯一的URL作为当前项目的访问地址。

### 2\. 页面 - Page

一个页面包含在一个特定的项目中。

页面可以设置页面的URL，也可以类似项目设置页面的访问权限，页面的访问权限优先级高于项目。

页面提供两个事件：页面加载完成、页面即将卸载。页面的设计者可以监听这两个事件进行一些操作，例如：页面加载完成后列表组件拉取数据展示数据列表。

页面提供两个动作：重新加载、跳转。页面设计者可以在当前页面响应其他事件的时候触发这些动作，例如：表单提交成功后跳转到详情页。

### 3\. 组件 - Component

组件是系统的核心，是页面上各个元素，包括输入框、下拉框、单选框、复选框这些对应原生HTML元素的组件，也包括列表、表单、详情页、导航栏等这种系统提供的快捷组件。

通常一个完整的页面由多个组件构成。

在页面上添加组件时，页面设计者需要设定组件的元信息，例如：输入框的标签、placeholder，表单要提交的API以及API的请求方式等。用户在访问该页面时，系统会根据预先设定的组件信息，渲染出完整的页面。

一个组件通常包含多个事件，这些事件可以被同一页面中的其他组件监听。例如：输入框的“内容变动（onChange）”事件，表单的”提交成功（onSubmitSuccess）“事件。

一个组件通常也包含多个内置的动作，这里的动作是系统自己触发的而不是用户触发的，动作触发后会触发相应的事件。例如：输入框有一个清空动作，清空动作触发后会触发”内容变动（onChange）“事件。

关于这个想法就说这么多吧，说起来挺简单，但是细细想想实现细节还是蛮复杂的。

## 三、新的技术

文章开始的时候说了，我不是一个喜欢守旧的人，所以在新的项目中我想使用新的技术。

1\. [ReactJS](https://facebook.github.io/react/)：Facebook推出的一个专注于开发前端组件的Javascript库，它不像AngulaJS、EmberJS那样大而全，ReactJS只专注于UI，专注于组件的渲染和更新。ReactJS通过jsx来编写前端DOM，可能很多同学刚接触有点接受不了，毕竟我们被逻辑、视图分离思想洗脑了这么多年了，但尝试之后感觉还是很不错的，各大编辑器对JSX语法都有支持。

2\. [Flux](https://facebook.github.io/flux/docs/overview.html)：同样是Facebook推出的，推荐与ReactJS配套使用的一种应用架构，注意Flux只是应用架构的一种思路，并不是一个框架。

3\. [Alt](http://alt.js.org/)：既然Flux是一个推荐与ReactJS配套使用的架构思想，那么理所应当的就来个框架呗，这就是ALT。

4\. [Webpack](http://webpack.github.io/)：这是一个打包工具，各路大神、包括ReactJS官方也是极力推荐的，之前介绍过Gulp，webpack可以取代Gulp来进行前端的构建工作，也可以配合使用。

上面四个是在该项目中用到的核心的几个技术点，但不是全部，还有前端路由、数据获取相关的东东会选用其他的库。

针对这些技术的学习笔记，后面的文章会陆续发出来，敬请期待。
