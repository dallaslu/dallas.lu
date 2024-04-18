---
title: Eclipse 启动参数
date: '2013-12-06 16:49'
author: 'dallaslu'

taxonomy:
    category:
        - Software
    tag:
        - Eclipse
        - Note

---
通过修改快捷方式的命令参数，可以实现两个快捷方式，分别打开工作区间不同的两个 Eclipse 实例，它们的配置也是独立的。那 Eclipse 还有哪些其他的很有用的启动参数呢？

===

指定工作区间参数，在 Windows 中，查看快捷方式的属性，修改「目标」为：

`"D:\Program Files\Eclipse\eclipse.exe" -data E:\Workspaces\dallaslu`

另外，我找到一份完整的 [Eclipse 启动参数列表](http://www.cnblogs.com/sunsonbaby/archive/2005/02/02/101112.html)，并摘录几条常用参数如下：

## 设置 Eclipse 界面语言

`eclipse.exe -nl "zh"`

## 不显示启动屏幕

`-nosplash`

## 标题中显示工作空间的位置

`-showlocation`

与 －data 参数一同使用，可在窗口标题中显示工作空间的路径，更便于区分。

## 指定 JVM

`-vm jvm-path`
