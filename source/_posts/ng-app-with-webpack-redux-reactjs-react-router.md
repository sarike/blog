---
title: 使用webpack、Redux、ReactJS、React-Router开发新一代的前端应用
tags:
  - Flux
  - JavaScript
  - ReactJs
  - Redux
  - webpack
  - 前端
id: 121
categories:
  - 技术笔记
date: 2016-03-19 22:27:50
---

不得不再次感慨，前端界的新技术真的是层出不穷，惊喜不断，许多同学估计已经蒙圈了…… 最近刚把这些技术在一个新项目中进行了实践，感觉确实不错，同时也踩了不少坑，希望通过这篇文章能鼓动起前端同学更新自己前端技术栈的勇气，也希望能让刚接触这部分知识的同学少走些弯路。

注：这是一篇概括性的文章，不可能在一篇文章内把这么多前端技术很详细的讲一遍，就算写了，估计也不会有人看。

#### 一、Webpack

[Webpack](http://webpack.github.io/)是一款强大的前端资源模块打包工具。前端资源有很多种，JavaScript文件，css文件，各种图片文件，.jade/.tpl等各种前端模板文件，还包括.less/.sass/.coffee等需要预处理的扩展语言文件。 对于Webpack来说，所有的前端资源都被看作是一个前端模块，你可以通过不同的[加载器（Loaders）](http://webpack.github.io/docs/loaders.html)或者插件来指定如何处理各种资源，例如： 

1. 你可以将所有的前端资源打包到一个JavaScript文件中去。你没有看错，就是有且仅有一个JavaScript。CSS文件会在运行时自动Inline到Head标签内，图片、字体文件可以直接以data url的的形式直接inline到css代码中。 

2. 上一种方式你一定会觉得，这样将产生一个比较大的JS文件，因为它包含了整站的前端资源，将会导致系统首次加载特别慢。确实是这样，所以我们可以这样：在打包的时候通过Webpack的插件（例如：[extract-text-webpack-plugin](https://github.com/webpack/extract-text-webpack-plugin)）将CSS代码打包到一个单独的样式文件中，对于图片、字体等文件，可以通过指定Loader的参数来告诉webpack，只有文件小于10K的才以Data URL的形式内联到CSS代码中，大于10K的以单独的文件加载。

3. 可能你还觉得即便是把CSS文件、图片文件、字体文件剥离出来，剩下的JavaScript代码合并到一起一样很大，还是没有解决问题。好吧，其实Webpack还有一个特性就是：[Code Splitting](http://webpack.github.io/docs/code-splitting.html), 我们可以根据系统的页面划分或者功能划分，将JavaScript代码打包到不同的JavaScript文件中去，通过CommonJS、AMD等模块化规范在需要的时候进行加载。 

PS：Webpack还提供了对应的开发工具，例如webpack-dev-server，可以通过--hot参数开启实时更新模式，只要代码有更新，自动帮你刷新页面，是不是很爽？ 再PS：Webpack相对于其他的前端资源打包工具（例如：Gulp/Grunt），它更适合大型的前端项目，并且能够更好地实现前端资源的按需加载。

<!--more--> 

#### 二、ReactJS

要问2015年哪个前端框架最火，那一定是[ReactJS](https://facebook.github.io/react/index.html)。 ReactJS是Facebook推出的用来构建前端交互组件的JS框架。 简单概括下ReactJS，ReactJS的使用其实很简单，使用ReactJS进行开发的过程就是一个构建各种前端组件的过程，一个组件是可以被复用的东东，它有这么几个概念：

*   **属性（props）**，可能是组件渲染需要的数据、回调函数，或者是状态标识（如：展示/隐藏），也可能是组件外观相关的背景色、尺寸等信息。
*   **状态（state）**，用来描述当前组件这一时刻的状态，当状态被改变时（setState)时，ReactJS会自动重新渲染组件。
*   **引用（ref）**，已用其实就是一个属性，它可以被父组件用来获取这个组件（this.refs.xxxx）。

##### 1\. JSX

JSX是对JavaScript语法的扩展，可以以一种XML类似的语法来渲染React组件。例如：

```javascript
//将一个div渲染到页面上Id为example的容器中
var myDivElement = &lt;div className="foo" /&gt;;
ReactDOM.render(myDivElement, document.getElementById('example'));
```

多年被逻/展示分离思想洗脑多年的Web开发者来说，看到这样的语法是否有点难以接受，至少我是有的，第一眼看到这玩意儿，这不就是把HTML代码写到JavaScript代码里去了吗，这怎么能忍。 React说了，如果你真不能忍，我也有纯JS的写法，例如上面的代码转换成对应的JavaScript代码就是：

```javascript
//将一个div渲染到页面上Id为example的容器中
var myDivElement = React.createElement('div', {className:"foo"});
ReactDOM.render(myDivElement, document.getElementById('example'));
```

不过根据我的亲身体验，还是感觉直接用JSX的语法更爽一些。主要有这么几点原因：

*   主流的IDE或者编辑器已经支持JSX语法。
*   在开发React组件时，应该适当细化组件，由各个小组件组成一个更大的组件。所以说在一个组件内不会出现大篇幅的JSX代码，如果你发现自己一个组件包含大篇幅的JSX代码，你应该考虑将组件拆分成更小的组件。而且小组件更容易被复用。

##### **2\. 虚拟DOM**

当我们编写JSX代码时，这些类似HTML DOM节点的标签，并不是真实的HTML DOM节点，而是需要ReactJS内部处理的虚拟DOM。 为什么要使用虚拟DOM呢，我们知道通过JavaScript直接操作HTML DOM是一个比较慢的过程，因为浏览器要重新计算网页文档的布局、计算CSS样式、重新进行页面的渲染，但是JavaScript的执行速度是很快的。 

虚拟DOM是对真实的HTML DOM的抽象，这样ReactJS就可以对抽象的虚拟DOM进行一些计算、对比，而无需将其交给浏览器去做那些耗时的事情，ReactJS知道如何在最好的时机以最好的方式将真实的DOM更新通知浏览器。 所以说，使用ReactJS构建大型项目时，即便是频繁更新页面，性能也是非常好的。 

参考：http://reactkungfu.com/2015/10/the-difference-between-virtual-dom-and-dom/

##### **3\. 单向数据流**

个人觉得实现单向数据流是构建大型前端Web应用的又一个保证，因为单向数据流，让应用的数据流变得简单、清晰、可预测，即便是在大型的WebApp中，也不会有种数据流混乱的感觉。 在ReactJS中，渲染前端组件时，当前组件在某一时刻如何展示，只关心此时此刻state就可以了，当用户触发了某个事件，或者成功请求API获取了部分数据时，只需要去更新state，组件在发现state跟新后会自动重新渲染。 Facebook是使用[Flux](https://facebook.github.io/flux/)架构来开发前端Web应用的，Flux只是一个前端应用的架构思想，并不是一个具体的框架。 下一节说的Redux可以认为是实现了Flux架构思想的一个具体框架，但不仅仅如此……

#### 三、Redux

[Redux](http://redux.js.org/index.html)是JavaScript应用的可预测的状态容器（Redux is a predictable state container for JavaScript apps.），这是Redux文档的第一句话，而且确实如此，Redux的责任就是来维护整个应用在某一时刻的状态，当应用有事情发生（Action）时，Redux会更新State，同时依赖State的UI部分也会自动更新。 Redux可以认为是Flux架构思想的一个具体实现，但需要注意的是，Redux与ReactJS没有什么关系，你同样可以将Redux与AngularJS、EmberJS甚至是原生JS一起来开发Web应用。

##### 1. Actions

Actions用来描述“发生了什么事情？”，例如：请求加载用户列表、添加一个用户等。 通常，一个Action是一个对象，一般由两部分组成：一是这个Action的类型，也就是说这个Action到底表达发生了什么事情；二是应用相应这个Action需要的数据，例如成功添加一个用户时，Action需要持有新用户的数据。 所以，成功添加一个用户的Action通常是这样的：

```javascript
{
    type: ADD_USER_SUCCESS,
    user: {id: 1, name: 'Jack'}
}
```

##### 2. Reducers

当Redux接收到一个Action时，需要根据Action持有的信息，更新State，从而进一步触发UI的更新，这就是由Reducer来完成的。 Reducer就是一个函数，它接收现在的State和当前接收到的Action作为参数，根据Action持有的数据，产生一个新的State，进而UI会根据这个新的State自动更新。假如当前的用户列表中有三个用户，对应的State可能是这样的：

```javascript
{
    users: [
        {
            id: 1, 
            name: 'Lucy'
        }, 
        {
            id: 2, 
            name: 'Tom'
        }, 
        {
            id: 3, 
            name: 'Lily'
        }
    ]
}
```

Reducer是这样的，包含了处理添加用户成功Action的逻辑：

```javascript
function (state, action) {
    if (state === undefined) {
        return {users: []}
    }
    switch(action.type) {
        case ADD_USER_SUCCESS:
            return state.users.concat(action.user);
        default:
            return state;
    }
}
```

这样应用的State就被更新了一次。

##### 3. Store

刚才说了，Action来描述“发生了什么”，Reducer根据Action来更新State。 Store就是用来将Action、Reducer关联到到一起来工作的东东。Store的主要有如下职责：

* 持有应用的state，就是我们上面频繁提到的state
* 通过调用store.getState()来获取应用的state
* 通过调用store.dispatch(action)来分发一个Action，从而执行Reducer更新state
* 通过调用store.subscribe(listener)来监听state的变化，当state变化时会调用listener
* store.subscribe(listener)的返回值是一个函数，执行这个函数可以取消这次注册。

#### 四、React-Redux

Redux提供了简单易用的单向数据流架构的实现，ReactJS提供了简单、高效的组件化支持，那么如何让他们更好地协同工作呢，这就是[react-redux](http://redux.js.org/docs/basics/UsageWithReact.html)做的事情。 

Redux与ReactJS合作时是这样一番场景：用户触发ReactJS组件上的一个事件，例如点击了一个按钮或者通过页面跳转等时间展示了新的组件，可以通过Redux的store分发（dispatch）一个Redux的Action，Redux的Reducer接收到Action之后根据Action的类型（type）以及其携带的数据，更新State，最新的State的字段作为ReactJS 组件的属性重新进行渲染，从而更新ReactJS组件。

##### 1. Provider

其实不用react-redux也可以让Redux和ReactJS协同工作，只是我们需要给每个React组件传递Redux的store属性，这样每个React组件订阅store的状态变化来更新自身的展示。这样做有两个问题：1）写起来麻烦。2）使得React组件与Redux强耦合到了一起，原本可以随处复用的React组件受到了Redux的约束。 像上面描述的，通过react-redux可以让React组件与Redux更好地协同工作。 Provider是react-redux模块提供的一个React组件，只需要在渲染虚拟DOM的根时指定一次Provider并将store作为属性传递个它，Provider可以通过React的context将store传递给所有的子树节点。

##### 2. connect([mapStateToProps], [mapDispatchToProps], [mergeProps], [options])

Provider通过context传递属性的做法，貌似没有实现React组件与Redux的解耦和，子组件里依然要通过this.context.store来获取store呀。 当然不会让你这么做，connect是react-redux的一个函数，执行函数会产生一个新的函数，将组件作为这个新函数的参数执行获得一个新的组件，在这个新的组件内部，react-redux模块会帮我们自动订阅Redux的state，当Redux的state有更新时，这个新的组件将会感知，从而更新我们自己的组件。 

connect各参数的作用大致如下所述： 

- mapStateToProps(state)：函数，将State中的某些字段映射成当前组件的属性。 
- mapStateDispatchToProps：函数或者对象，如果是函数，函数将接收Redux的dispatch作为参数，你可以根据你自己的实际需求将dispatch绑定到你的actionCreator上去，函数需要返回一个对象，对象的字段会作为组件的属性传递给组件；如果是一个对象，对象的值是actionCreators，react-redux会将所有的actionCreator与dispatch进行绑定封装，在组件中直接调用即可实现对相应Action的分发；如果没有指定该参数，默认会将disaptch作为组件的属性传递给组件。 
- mergeProps(stateProps, dispatchProps, ownProps)：函数，默认值是：Object.assign({}, ownProps, stateProps, dispatchProps) ，该函数接收前两个参数作用的结果以及parent props，你可以重新组织组件的属性。 如下代码所示： 新建了一个ArticleList组件，并通过connect将该组件与Redux进行关联，将Redux的state的所有字段映射为ArticleList组件的属性，并将actionCreators的所有Action生成器作为connect的第二个参数，这样使用dispatch包装的actionCreator就会映射为ArticleList的组件，我们可以在ArticleList组件内直接调用这些属性来分发Action，如我们在组件过载到页面上时，分发了FETCH_ARTICLES这个Action。

```javascript
var actionCreators = {
    fetchArticles: function () {
        return {
            type: 'FETCH_ARTICLES'
        }
    }
};

var ArticleList = React.createClass({
    componentDidMount: function () {
        this.props.fetchArticles();
    },
    render: function() {
        return (
            <div></div>;
        );
    }
});

module.exports = ReactRedux.connect(function (state) {
    return state;
}, actionCreators)(ArticleList);
```

##### 3. 容器组件与展示组件

通过connect我们可以很方便的实现对Redux的state的订阅，但是，这貌似还是没有让组件与Redux进行解耦和，还是很不方便对这些组件进行复用。 唉……很遗憾，框架能为我们做的就只有这么多了，剩下的就全靠我们自己了，不过庆幸的是，通过合理组织自己的组件，分离容器组件与展示组件，我们很容易将展示组件与Redux分离。 那么什么是容器组件与展示组件呢？大家可以参考下[这篇文章](https://medium.com/@dan_abramov/smart-and-dumb-components-7ca2f9a7c7d0#.beoz57sit)。 

- **容器组件** 容器组件通过connect与Redux进行关联，容器组件能感知到Redux的存在，它知道如何分发Action来更新系统状态，容器组件包含许多展示组件，并将Redux的state中的数据分配到各个展示组件的属性上，这样当容器组件感知到state更新而重新渲染时会跟新展示组件的属性，从而重新渲染展示组件。 
- **展示组件** 展示组件就是我们编写的，用来描述页面上特定区域如何来展示，它感知不到Redux的存在，所有的数据通过属性来获取，想要更新数据时，通过执行回调函数属性来实现，展示组件往往是容器组件的Children，展示组件在触发自身的回调函数属性时往往会触发容器组件的成员方法以分发某个Action，从而更新Redux的state，state更新后，容器组件会被重新渲染，同时更新展示组件的属性来更新展示组件。

#### 五、React-Router

使用这么高达上的前端技术，往往会用来开发用户体验更好的单页应用，单页应用只会加载一个Document，所有的“页面”切换实际上都是动态更改DOM，那么当某些情况用户强制刷新页面时，如何保证还能保持当前页面状态呢，或者说当你的同事copy给你一个连接时，如何保证你打开后看到的页面内容跟你同事看到的页面内容是一致的呢。 这就是前端路由要做的事情，[React-Router](https://github.com/rackt/react-router)以React组建的形式，为我们实现了一种简单直观来定义前端路由的方式。 当我们使用Redux的时候，我们还会用到另外一个模块：[React-router-Redux](https://github.com/reactjs/react-router-redux) ,该模块将路由状态同步到Redux的State，并提供了一系列的Action来方便我们更新路由状态。
