---
title: 勇敢的小白鼠
date: '2008-11-21 03:16'
author: 'dallaslu'

taxonomy:
    category:
        - WordPress
    tag:
        - Theme
        - Upgrade

---
现在已经是 WordPress 2.7 beta3 了。主题是经过修改的 <a href="http://www.neoease.com/" target="_blank" title="访问其博客">MG12</a> 的 <a href="http://www.neoease.com/blocks/" target="_blank" title="这个主题的详细信息">Blocks</a> 。

===

目前感觉良好。

首先我是用 phpMyadmin复制了博客数据到一个新的数据库中，然后上传了 WordPress 2.7 的程序文件到一个新建的目录，写好配置文件。直接升级，没出现什么问题。

然后闯进后台一通设置、测试。不错，支持评论嵌套、文章和页面的快速编辑、超强的插件管理，还有一些细节的地方也很好。

接着就是把 2.6 中我使用的插件主题拷贝过来进行测试，嘿嘿，大部分没发生兼容问题。这些插件包括：

* <a href="http://wpaudioplayer.com/" target="_blank" title="访问插件主页">Audio player</a>
* <a href="http://fairyfish.net/2008/06/04/blank-target-for-comment/" target="_blank" title="访问插件主页">Blank Target for Comment</a>
* <a href="http://www.viper007bond.com/wordpress-plugins/clean-archives-reloaded/" target="_blank" title="访问插件主页">Clean Archives Reloaded</a>
* <a href="http://www.stimuli.ca/lightbox/" target="_blank" title="访问插件主页">Lightbox 2</a>
* <a href="http://www.arnebrachhold.de/redir/sitemap-home/" target="_blank" title="访问插件主页">Google XML Sitemaps</a>
* <a href="http://alexrabe.boelinger.com/?page_id=80" target="_blank" title="访问插件主页">NextGEN Gallery</a>
* <a href="http://www.ilfilosofo.com/blog/wp-db-backup" target="_blank" title="访问插件主页">WordPress Database Backup</a>
* <a href="http://fairyfish.net/2007/09/12/wordpress-23-related-posts-plugin/" target="_blank" title="访问插件主页">WordPress Related Posts</a>
* <a href="http://lesterchan.net/portfolio/programming/php/" target="_blank" title="访问插件主页">WP-PostViews</a>

但是，<a href="http://blog.istef.info/wp-turbo" target="_blank" title="访问插件主页">WP-Turbo</a> 、<a href="http://goto8848.net/projects/custom-smilies/" target="_blank" title="访问插件主页">Custom Smilies</a> 这两个插件貌似有些问题。

本来就打算换个主题了，加之因为原来的主题评论输入区在侧边浮动，不太适合搞成支持评论嵌套的，所以换了现在这一款。其间找了许多个主题，最后因为 iNOVE 而看到了 MG12 的 Blocks 系列。然后下载了 Blocks 和 Blocks2 ，两款都不错，但是它们让我难以取舍，于是乎修改了 Blocks （CSS 、布局居然又参照了 Blocks2，纠结），就是现在的主题了，似乎，可以叫做 Blocks1.5 哈～。

其实整个过程没有上面讲的那么顺利，比方说有几个文件出错，不得不重新上传；差点忘记，那个 NextGEN Gallery 跟这个主题有一点小冲突，启用这个插件会导致文章页面的“上一篇、下一篇”链接那里风格诡异。最后解决办法是在 style.css 和 single.php 中找到 prev、next 这两个 class 名，分别改为 prevpost、nextpost，问题解决。

今天鼓捣了好长时间，又学到不少东西。不过，现在有两个纠结的问题:

1. 这个 Blocks 的载入 sidebar 的方法，貌似不在 single.php 和 page.php 里，本来打算搞个没有 sidebar 的页面模板的;
2. WordPress 2.7 中怎么实现在留言页面倒序显示评论？就是说新的留言排在上面。

如果有解决办法记得告诉我哈，在此评论、[留言](https://dallas.lu/guestbook/)、[联系我](http:s//dallas.lu/about)都可以，先谢啦～。
