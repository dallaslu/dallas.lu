---
title: 短网址程序 YOURLS
date: '2009-06-27 14:12'
author: 'dallaslu'

taxonomy:
    category:
        - Internet
    tag:
        - PHP
        - Yourls

---
一直以来都琢磨着自己搭建一个短网址服务，给自己用。虽然我的域名不是很短，但总比 tinyurl 短吧？在“我爱水煮鱼”那看到了 YOURLS 的介绍，遂试用一番。

===

我试过功能强大些的 Shorty、WordPress 的插件 Pretty Link，甚至还下载了一份据说是泄漏出来的 Tinyurl 源码。但是 YOURLS 的简单、简洁吸引了我。关于 YOURLS 的介绍请移步《[使用 YOURLS 创建自己的 URL 缩短服务](http://fairyfish.net/2009/06/26/yourls/)》。

## 安装配置

<div class="download"><a href="http://code.google.com/p/yourls/downloads/list">Download YOURLS </a>
from Google Code</div>

其实配置起来也不是很复杂，多了几个站点设置而已。参考水煮鱼的介绍。

## WordPress 插件

这个插件还支持其他的短网址服务，例如 tr.im, is.gd, tinyurl.com 以及 bit.ly 。所以，即使你没安装 YOURLS 的程序，也能用到这个插件。这个插件会为博客里的文章生成短网址链接并发送到指定 Twitter 账户。

WordPress 2.7 即更高版本中可访问 插件&gt;添加，输入 YOURLS 来搜索安装。

## API 书签

虽然有了 YOURLS，但是添加新网址的时候还真是麻烦，复制来复制去的，还要访问新页面。好在有 API，完全可以做个快捷书签来帮助我们生成短网址。地址栏是可以在当前页面运行 JavaScript 代码的，可以利用这个免去一点麻烦。如果你安装了 YOURLS，可以在这里生成一个简单的书签（阅读器中可能无效，GR 用户请按 V）：

<div id="yourls-get-bookmark">

API：<input class="textfield" id="yourls-site" type="text"/>/yourls-api.php

用户：<input class="textfield" id="yourls-username" type="text"/>

密码：<input class="textfield" id="yourls-password" type="text"/>
</div>

<button class="button" id="yourls-get">生成</button> <span id="yourls-get"></span>

怎么样，还是很拉风的吧。
