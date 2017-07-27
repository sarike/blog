---
title: 炫酷的npx 
date: 2017-07-27 10:37:24
tags:
---

以前感觉 npm 安装过程太慢，没有lock文件而转而使用yarn来管理项目依赖。

npm@5 发布以后，因为yarn用的好好的，所以也没有太关注。

因为 npm@5 也加入了 lock 文件，而且在性能和安装效率上也有大幅提升，团队希望使用 npm，毕竟是亲儿子嘛。

刚才打开npm releases 看了一下，没想到被一个叫 npx 的小工具给吸引住了，What's this?

npx 是跟随 npm@5.2 一起发布的，而且在介绍中频繁使用 cool 这个单词，足以见得官方对它的宠爱，我只想说能不能低调点。

不过，了解过后，情不自禁：COOOOL!

下面挑几个直击痛点的 feature 介绍一下：

## 直接运行各种命令行工具模块

就我个人而言，安装了各种各样的命令行工具，像 hexo，create-react-app、serve 等，但是这些工具用的不是很频繁，用过一次之后下次在用的时候，发现已经有了个更新的版本，所以不得不再重新安装一次。

有了 npx，只需要：

```bash
npx create-react-app <project-name>
```

每次都是最新版本，而且不会污染全局模块，就像是 npm 仓库里所有的命令行工具都已经给你安装好了似的。Cool!

是不是感觉除了一些常用的，大部分命令行工具都可以卸载了？至少我已经卸载了。

## 直接运行本地安装的命令行工具，无需配置 run-script

很多情况下本地安装的包会带一些命令行工具，例如 webpack，但是有些强迫症患者（比如我），就是不想把它全局安装，肿么办呢？

当然，你可以配置 npm scripts，但是我也不想这么办。

有了 npx，你可以这么办：

```bash
npx webpack
```

其实跟上一个 feature 是一样的，npx 执行一个命令会优先查看本地安装，没有的话会从仓库获取并执行。

## 切换 node 版本

我会使用 nvm 来管理我系统中的多个 node 版本。

有了 npx，nvm 同样可以卸载了。

{% asset_img npx-node-version.png 使用不同的node版本%}

参考：https://medium.com/@maybekatz/introducing-npx-an-npm-package-runner-55f7d4bd282b

