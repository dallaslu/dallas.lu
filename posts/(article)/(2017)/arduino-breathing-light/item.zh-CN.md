---
title: Arduino 炫彩呼吸灯
date: '2017-10-18 20:37'
author: 'dallaslu'

taxonomy:
    category:
        - Default
    tag:
        - Arduino
keywords:
  - 呼吸灯算法
---
最近为了做一个猫咪自动喂食器，买了一堆开发板和各种传感器等元件。苦于外壳方案未定，迟迟没有进展。于是拿手头的东西做了一个呼吸灯，看上去还不错。

===

效果：

<https://www.youtube.com/watch?v=3v5ioNXJQuQ>

代码如下：

<https://gitlab.com/snippets/1719900>

一开始不知道这个灯珠是共阳的，换了很多种接法都不亮，标记 “-” 符号的针脚不接 GND，而是接 5V 输入。后面以为和常见的颜色编码一样 0 是最暗、255 是最亮，试了很多次才恍然大悟：因为是共阳，所以是反的，255 是最暗，0 是最亮。
