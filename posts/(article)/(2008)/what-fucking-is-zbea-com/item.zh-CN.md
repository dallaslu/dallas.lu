---
title: zbea.com 是个啥东西
date: '2008-11-16 01:57'
author: 'dallaslu'

taxonomy:
    category:
        - Fucking
    tag:

---
突然发现，我的404页面变成了 http://www.zbea.com/404.htm 。截图如下：

![](zbea404.jpg)

从网页最后的文字来看：

> HTTP 错误 404 - 文件或目录未找到。Internet 信息服务 (IIS)

应该不是服务器的东西，因为我用的主机是 Linux 操作系统的。而且，我现在发觉无论是打开主页或者后台，火狐的状态栏都提示“正在等待 www.zbea.com ……”之类的文字。

丫的，<a href="http://www.google.cn/search?hl=zh-CN&newwindow=1&rlz=1B3GGGL_zh-CNCN280CN281&q=www.zbea.com&btnG=Google+%E6%90%9C%E7%B4%A2&meta=cr%3DcountryCN&aq=f&oq=" target="_blank">Google 了一下</a>，发现都是些域名倒卖之类的东西，居然还有个上有框架引用该站的某个页面的代码，0宽0高，估计是木马之类的东东。

但是我的页面代码里根本没有zbea.com的东西，难道是某个插件搞的鬼？顺便检查了所引用的各个插件的 js 文件，以及 .htaccess 文件，都没发现问题。

我X了！
