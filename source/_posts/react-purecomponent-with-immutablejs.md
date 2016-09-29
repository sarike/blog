---
title: React.PureComponent 配上 ImmutableJS 才更有意义
date: 2016-09-29 23:27:21
tags:
 - ImmutableJS
 - React
 - PureComponent
---

前段时间ReactJS发布的 [v15.3.0](https://github.com/facebook/react/releases/tag/v15.3.0) 中针对ES6语法，增加了一个新的组件基类：React.PureComponent。

之前，使用ES6语法开发的同学，为了避免不必要的render开销，可能会像官方文档介绍的那样，这样来使用[PureRenderMixn](https://facebook.github.io/react/docs/pure-render-mixin.html):

```javascript
import PureRenderMixin from 'react-addons-pure-render-mixin';
class FooComponent extends React.Component {
  constructor(props) {
    super(props);
    this.shouldComponentUpdate = PureRenderMixin.shouldComponentUpdate.bind(this);
  }

  render() {
    return <div className={this.props.className}>foo</div>;
  }
}

```

或者直接[这样](https://facebook.github.io/react/docs/shallow-compare.html)：

```javascript
var shallowCompare = require('react-addons-shallow-compare');
export class SampleComponent extends React.Component {
  shouldComponentUpdate(nextProps, nextState) {
    return shallowCompare(this, nextProps, nextState);
  }

  render() {
    return <div className={this.props.className}>foo</div>;
  }
}
```


有了React.PureComponent之后，可以这样：

```javascript
export class SampleComponent extends React.PureComponent {
  render() {
    return <div className={this.props.className}>foo</div>;
  }
}
```
实际上跟之前两种方式是等价的，但是写起来会更加简介优雅。

好，背景介绍完了，下面进入正题，聊一聊 `React.PureComponent`、`PureRenderMixin`、`shallowCompare`如何帮助我们避免额外的 render 开销，提高性能，以及为什么说他们配上 ImmutableJS才更有意义。

按照我们直观的理解，当我们使用了 `PureComponent ` 作为组件基类时，如果组件的props或者state没有发生变化，就不应该重新渲染组件，这里说的 “没有发生变化”，不是指语言层面的 === 或者 ==，而是指新的 props 或者 state 不会对组件的渲染结果产生任何的影响。

看下面这个例子：

```javascript
class Sample extends React.PureComponent{
  
  constructor(props) {
    super(props);
    this.state = {
      name: 'Lucy',
      pet: {
        type: 'cat',
        color: 'red',
      }
    };
  }
  
  componentDidUpdate() {
    console.log('did update');
  }
  
  change() {
    this.setState({
      name: this.refs.name.value,
      pet: {
        color: this.refs.petColor.value,
        type: this.refs.petType.value
      }
    });
    
  }
  
  render() {
    const name = this.state.name;
    const petC = this.state.pet.color;
    const petT = this.state.pet.type;
    return (
      <div>
        <strong></strong>
          <div>{name}'s pet is a {petC} {petT}.</div>
        <hr/>
        <p>
          name: 
          <input type="text" ref="name" defaultValue={name}/>
        </p>
        <p>
          pet color: 
          <input type="text" ref="petColor" defaultValue={petC}/>
        </p>
        <p>
          pet type: 
          <input type="text" ref="petType" defaultValue={petT}/>
        </p>
        <button onClick={() => this.change()}>Change</button>
      </div>
    );
  }
}

ReactDOM.render(<Sample/>, document.getElementById('root'));
```

在这个例子中，直接点击 “Change” 按钮，不会对 state 产生任何影响组件最终渲染结果的更改，在这种情况下我们是期望组件不要重新渲染的。

我在 componentDidUpdate 中添加了一条日志输出，如果控制台有输出 “did update” 则说明组件被重新渲染了。

现在直接点击 “Change” 按钮，能看到控制台输出“did update”，这是为什么呢？

**NOTE：** 即便是使用 PureRenderMixn和shallowCompare都是一样的，不信可以自己试验一下，文章后面的内容也会说明这一点。

为了弄清楚这个问题，让我们扒拉一下React的源码。

[代码连接](https://github.com/facebook/react/blob/v15.3.2/src/renderers/shared/stack/reconciler/ReactCompositeComponent.js#L816)

```javascript
if (this._compositeType === CompositeTypes.PureClass) {
  shouldUpdate =
    !shallowEqual(prevProps, nextProps) ||
    !shallowEqual(inst.state, nextState);
}
```
这里的 shouldUpdate 变量就是在后面的逻辑中标识该不该重新渲染组件的，这里有个 `shallowEqual` 函数，我们暂且不表。

我们再看一下 PureRenderMixin 的代码：

[代码链接](https://github.com/facebook/react/blob/v15.3.2/src/addons/ReactComponentWithPureRenderMixin.js)

```javascript
var ReactComponentWithPureRenderMixin = {
  shouldComponentUpdate: function(nextProps, nextState) {
    return shallowCompare(this, nextProps, nextState);
  },
};

module.exports = ReactComponentWithPureRenderMixin;
```

这个Mixin就是帮我们实现了 `shouldComponentUpdate ` 函数，原来这里用到了 `shallowCompare ` 方法，那好，我们继续看看 `shallowCompare` 方法的代码：

[代码链接](https://github.com/facebook/react/blob/v15.3.2/src/addons/shallowCompare.js)

```javascript
function shallowCompare(instance, nextProps, nextState) {
  return (
    !shallowEqual(instance.props, nextProps) ||
    !shallowEqual(instance.state, nextState)
  );
}
```

OK！OK! 看到了吧，`shallowCompare` 也是对 `shallowEqual` 的封装，所以文章开头描述的三种方式归根揭底都是一样的。

**那么我们现在只要搞清楚 `shallowEqual` 方法是怎么实现的，上面的问题就真相大白了**，看代码：

[代码链接](https://github.com/facebook/fbjs/blob/master/packages/fbjs/src/core/shallowEqual.js) 

**NOTE：** `shallowEqual` 不是ReactJS的代码，它是Facebook的一个工具库：fbjs。

这个方法重点关注两个点：

1. 如它的名字一样，这个方法只进行对象的浅比较，我们知道deepCompare是无脑递归操作，开销会比较大，得不偿失的。
2. 比较对象属性的值，用的是 [Object.is](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/is) 方法。

```JavaScript
Object.is(
  {
    pet: {
      color: "red", type: "cat"
    }
  }, 
  {
    pet: {
      color: "red", type: "cat"
    }
  }
) === false;
```

所以说最终原因是因为我们的 state 嵌套了一个 pet 对象，更新 state 时，pet被换成了一个新的对象，导致浅比较通过不了。

问题原因找到了，由此我们可以看到，`shallowCompare`只会当组件的 state 或者 props 没有嵌套结构的时候才会正确按照预期发挥作用，然而在实际的项目中，嵌套的 state 或者 props 结构是很常见的，所以我认为单纯使用`React.PureComponent`是实际应用中时没有什么卵用的，那我们如何规避这个问题以满足我们的期望呢，这就是 [ImmutableJS](https://facebook.github.io/immutable-js/) 的意义。

ImmutableJS 是为了解决 JavaScript 语言层面上没有不可变 Data 的问题，ImmutableJS 提供了许多不可变的数据结构，对原始数据的更新会生成一个新的 Immutable 对象，所以可以放心大胆的操作；同样，如果一个操作没有对数据的值进行实质性的更新，那么操作的结果还是跟操作之前的一模一样，这也是通过 ImmutableJS 可以解决我们今天的问题的关键所在。另外 ImmutableJS 还提供了功能强大且方便的API，想要了解更多信息可以查看其 [官方文档](https://facebook.github.io/immutable-js/)，这里就不展开赘述了，熟悉 ImmutableJS 的API之后，你就会发现它能做的时候远不止本文中这一丢丢。

下面我们使用ImmutableJS对之前的例子进行改造，如下所示：


```javascript
class Sample extends React.PureComponent{
  
  constructor(props) {
    super(props);
    this.state = {
      name: 'Lucy',
      pet: Immutable.fromJS({
        type: 'cat',
        color: 'red',
      })
    };
  }
  
  ...
  
  change() {
    this.setState({
      name: this.refs.name.value,
      pet: this.state.pet
              .set('color', this.refs.petColor.value)
              .set('type', this.refs.petType.value)
    }); 
  }
  
  render() {
    const name = this.state.name;
    const petC = this.state.pet.get('color');
    const petT = this.state.pet.get('type');
    
    ...
}

...
```
 
 
现在我们再点击 “Change”按钮，控制台就不会再输出“did update”了。