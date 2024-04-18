---
title: CSS 悬浮盒菜单
date: '2009-04-27 21:59'
author: 'dallaslu'
published: false

taxonomy:
    category:
        - Internet
    tag:
        - Css
        - Menu

---
看完史密斯的《CSS 悬浮画廊》之后，我觉得利用这办法也可以用来搞个拉风的菜单。鼠标悬浮其上时，菜单项会变得很大，盖住附近的菜单项或者其他元素。

===

原始的悬浮盒代码使用了两个 `img` 元素，一个是缩略图，另一个大一点儿。菜单应该避免复制本身的链接，我也想用 CSS 来控制图片而不是用 `img` 。所以得改改代码了。

## HTML

    &lt;div id="menu"&gt;
    &lt;ul&gt;
    &lt;li id="home"&gt;&lt;a href="/"&gt;&lt;span&gt;&lt;em&gt;News&lt;/em&gt;&lt;/span&gt;&lt;/a&gt;&lt;/li&gt;
    &lt;li id="about"&gt;&lt;a href="/about/"&gt;&lt;span&gt;&lt;em&gt;About&lt;/em&gt;&lt;/span&gt;&lt;/a&gt;&lt;/li&gt;
    &lt;li id="sketches"&gt;&lt;a href="/sketchbook/"&gt;&lt;span&gt;&lt;em&gt;Sketches&lt;/em&gt;&lt;/span&gt;&lt;/a&gt;&lt;/li&gt;
    &lt;li id="videos"&gt;&lt;a href="/videos/"&gt;&lt;span&gt;&lt;em&gt;Videos&lt;/em&gt;&lt;/span&gt;&lt;/a&gt;&lt;/li&gt;
    &lt;li id="store"&gt;&lt;a href="/store/"&gt;&lt;span&gt;&lt;em&gt;Store&lt;/em&gt;&lt;/span&gt;&lt;/a&gt;&lt;/li&gt;
    &lt;li id="links"&gt;&lt;a href="/links/"&gt;&lt;span&gt;&lt;em&gt;Links&lt;/em&gt;&lt;/span&gt;&lt;/a&gt;&lt;/li&gt;
    &lt;/ul&gt;
    &lt;/div&gt;

用 span 标签来控制菜单条目的样式，最里面又套了个 em 则是为了需要时把它藏起来。

## 图片（可选）

大幅

http://www.designmeme.com/articles/hoverboxmenu/
